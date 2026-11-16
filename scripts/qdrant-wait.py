#!/usr/bin/env python3
"""Wait until the index has caught up with the files you changed.  python3 scripts/qdrant-wait.py [REPO_PATH] [--timeout 1800]
Indexing is SLOW (about 2.4 chunks/s on CPU: a 100 KB change takes ~20 s, a whole repo minutes, the first full index ~2 hours) and Qdrant optimises in the background.
Never trust a search made right after an edit.  This script: (1) runs reindex_changes for REPO_PATH through the MCP server, (2) waits until every Qdrant collection is green
(optimizer idle) and its point count is stable for 15 s.  Exit 0 = in sync, 1 = timeout."""
import json,sys,time,urllib.request,subprocess,os
def get(p): return json.load(urllib.request.urlopen('http://localhost:6333'+p,timeout=10))['result']
a=sys.argv[1:]; timeout=int(a[a.index('--timeout')+1]) if '--timeout' in a else 1800; repo=next((x for x in a if not x.startswith('--') and x!=str(timeout)),None)
here=os.path.dirname(os.path.abspath(__file__))
if repo: subprocess.run([sys.executable,here+'/qdrant-index.py',repo],check=False)
t0=time.time(); last=None; stable=0
while time.time()-t0<timeout:
    cols=[c['name'] for c in get('/collections')['collections']]
    info=[get('/collections/'+c) for c in cols]
    state=(tuple(i['points_count'] for i in info),all(i['status']=='green' and i['optimizer_status']=='ok' for i in info))
    stable=stable+1 if state==last and state[1] else 0; last=state
    if stable>=3: print('in sync: %d collections, %d points (%.0fs)'%(len(cols),sum(state[0]),time.time()-t0)); sys.exit(0)
    time.sleep(5)
print('TIMEOUT: still changing after %ds'%timeout); sys.exit(1)
