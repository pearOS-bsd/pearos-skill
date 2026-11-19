#!/usr/bin/env python3
"""Export the whole Qdrant index as a 3D map: python3 scripts/qdrant-map.py OUTDIR   (use ~/.pear/venv/bin/python for UMAP)
Writes OUTDIR/points.json: every chunk as a point (x,y,z from UMAP of the 768-d vectors, falling back to PCA), its repository, file, lines and a snippet, plus "links":
pairs of chunks of DIFFERENT repositories whose vectors are almost the same (cosine >= 0.90): the same idea implemented twice (see RULES 16)."""
import json,os,sys,time,urllib.request,collections
import numpy as np
out=sys.argv[1] if len(sys.argv)>1 else '.'; os.makedirs(out,exist_ok=True)
Q='http://localhost:6333'
def req(path,body=None):
    r=urllib.request.Request(Q+path,json.dumps(body).encode() if body is not None else None,{'Content-Type':'application/json'})
    return json.load(urllib.request.urlopen(r,timeout=120))['result']
cols=[c['name'] for c in req('/collections')['collections']]
vec=[];meta=[]
for c in cols:
    off=None
    while True:
        r=req('/collections/%s/points/scroll'%c,{'limit':512,'offset':off,'with_payload':True,'with_vector':True})
        for p in r['points']:
            pl=p['payload']; base=os.path.basename(pl.get('codebasePath','').rstrip('/'))
            repo=base[:-5] if base.endswith('-test') else base
            if not repo or not pl.get('relativePath'): continue  # payload without a repository/file: not a real chunk
            vec.append(p['vector']); meta.append((repo,pl.get('relativePath',''),pl.get('startLine',0),pl.get('endLine',0),(pl.get('content','')[:110]).replace('\n',' ')))
        off=r.get('next_page_offset')
        if off is None: break
n=len(vec); print('points',n,'collections',len(cols))
if n==0: json.dump({'updated':time.time(),'repos':[],'files':[],'x':[],'y':[],'z':[],'r':[],'f':[],'l':[],'e':[],'t':[],'links':[]},open(out+'/points.json','w')); sys.exit(0)
X=np.asarray(vec,dtype=np.float32); X/=np.maximum(np.linalg.norm(X,axis=1,keepdims=True),1e-9)
try:
    import umap
    P=umap.UMAP(n_components=3,metric='cosine',n_neighbors=15,min_dist=0.1,random_state=42).fit_transform(X) if n>20 else None
except Exception as e: print('umap not available:',e); P=None
if P is None:
    Xc=X-X.mean(0); u,s,vt=np.linalg.svd(Xc,full_matrices=False); P=(Xc@vt[:3].T) if n>=3 else np.zeros((n,3))
P=np.asarray(P,dtype=np.float32); P-=P.mean(0); P/=max(np.abs(P).max(),1e-9)
repos=sorted({m[0] for m in meta}); ri={r:i for i,r in enumerate(repos)}; files=[]; fi={}
for m in meta:
    k=m[0]+'/'+m[1]
    if k not in fi: fi[k]=len(files); files.append(k)
links=[]
rid=np.array([ri[m[0]] for m in meta])
for a in range(0,n,1024):
    S=X[a:a+1024]@X.T
    for i in range(S.shape[0]):
        g=a+i; row=S[i]; row[g]=-1; row[rid==rid[g]]=-1
        j=int(row.argmax())
        if row[j]>=0.90 and g<j: links.append([g,j,round(float(row[j]),3)])
json.dump({'updated':time.time(),'repos':repos,'files':files,'x':[round(float(v),4) for v in P[:,0]],'y':[round(float(v),4) for v in P[:,1]],'z':[round(float(v),4) for v in P[:,2]],
  'r':[ri[m[0]] for m in meta],'f':[fi[m[0]+'/'+m[1]] for m in meta],'l':[m[2] for m in meta],'e':[m[3] for m in meta],'t':[m[4] for m in meta],'links':links[:3000]},open(out+'/points.json','w'),separators=(',',':'))
print('written',out+'/points.json','links',len(links))
