#!/usr/bin/env python3
"""Search ALL repositories at once (the MCP search_code searches one path).  RULES 16: run this before writing any utility/wrapper/component.
  python3 scripts/qdrant-search.py "mach port allocate" [-n 8] [--repo d]
Embeds the query with the same model as the index (Ollama), asks every Qdrant collection, merges by score. Output: score repo/file:start-end, first line."""
import json,sys,urllib.request
Q='http://localhost:6333'; O='http://localhost:11434'; M='unclemusclez/jina-embeddings-v2-base-code'
def post(u,d): return json.load(urllib.request.urlopen(urllib.request.Request(u,json.dumps(d).encode(),{'content-type':'application/json'}),timeout=120))
a=sys.argv[1:]; n=8; only=None; q=[]
while a:
    x=a.pop(0)
    if x=='-n': n=int(a.pop(0))
    elif x=='--repo': only=a.pop(0)
    else: q.append(x)
q=' '.join(q)
if not q: sys.exit(__doc__)
v=post(O+'/api/embeddings',{'model':M,'prompt':q})['embedding']
hits=[]
for c in json.load(urllib.request.urlopen(Q+'/collections'))['result']['collections']:
    try: r=post(f"{Q}/collections/{c['name']}/points/search",{'vector':v,'limit':n,'with_payload':True})['result']
    except Exception: continue
    for p in r:
        pl=p['payload']; repo=(pl.get('codebasePath') or '').rstrip('/').split('/')[-1]
        if only and repo!=only: continue
        hits.append((p['score'],repo,pl.get('relativePath','?'),pl.get('startLine'),pl.get('endLine'),(pl.get('content') or '').strip().split('\n')[0][:90]))
for s,repo,f,a1,b1,l in sorted(hits,reverse=True)[:n]: print(f"{s:.3f} {repo}/{f}:{a1}-{b1}  {l}")
