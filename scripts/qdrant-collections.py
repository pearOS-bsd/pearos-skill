#!/usr/bin/env python3
"""Which Qdrant collection is which repository?  (names are code_<hash of the path>)   python3 scripts/qdrant-collections.py"""
import json,urllib.request
Q='http://localhost:6333'
def g(u,d=None): return json.load(urllib.request.urlopen(urllib.request.Request(u,json.dumps(d).encode(),{'content-type':'application/json'}) if d else u))
rows=[]
for c in g(Q+'/collections')['result']['collections']:
    n=c['name']; pts=g(f'{Q}/collections/{n}')['result']['points_count']
    sc=g(f'{Q}/collections/{n}/points/scroll',{'limit':50,'with_payload':['codebasePath']})['result']['points']
    repo=next((p['payload']['codebasePath'].rstrip('/').split('/')[-1] for p in sc if 'codebasePath' in p['payload']),'?')
    rows.append((repo,n,pts))
for r,n,p in sorted(rows,key=lambda x:x[0].lower()): print(f'{r:22} {n}  {p:5} points')
print(f'{len(rows)} collections, {sum(r[2] for r in rows)} points')
