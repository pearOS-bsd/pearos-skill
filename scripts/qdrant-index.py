#!/usr/bin/env python3
"""Index (or re-index) pearOS repositories into the local Qdrant through the qdrant MCP server, WITHOUT using any LLM tokens:
it speaks MCP (JSON-RPC over stdio) to the server directly.
  python3 scripts/qdrant-index.py [--full] [REPO ...]        (default: every repository in $PEAR_DIR, ~/pearOS)
  python3 scripts/qdrant-index.py --tool search_code --path ~/pearOS/d --query "launchd bootstrap"      (a search, for testing)
Needs: Qdrant on :6333, Ollama with unclemusclez/jina-embeddings-v2-base-code, ~/.pear/qdrant-mcp-server built (scripts/qdrant-setup.sh)."""
import json,os,subprocess,sys,time,glob
HOME=os.path.expanduser('~'); PEAR=os.environ.get('PEAR_DIR',HOME+'/pearOS')
NODE=os.environ.get('NODE_BIN') or (sorted(glob.glob(HOME+'/.nvm/versions/node/v22*/bin/node')) or ['node'])[-1]
SERVER=HOME+'/.pear/qdrant-mcp-server/build/index.js'
ENV=dict(os.environ,EMBEDDING_PROVIDER='ollama',EMBEDDING_MODEL='unclemusclez/jina-embeddings-v2-base-code',QDRANT_URL='http://localhost:6333',LOG_LEVEL='error',CODE_BATCH_SIZE=os.environ.get('CODE_BATCH_SIZE','8'),EMBEDDING_RETRY_ATTEMPTS='5',
  CODE_CUSTOM_IGNORE=os.environ.get('CODE_CUSTOM_IGNORE','upstream/**,catalogs/**,**/*.car,**/*_Generated.*,iso/manifest/**,**/*.txt,**/*.json,**/golden/**,**/*golden*,**/sls_generic.c,**/sls_blobs.c,**/sls_harvest.c,**/sls_hotkey_defaults.c,**/macprobe-out/**,**/build/**,**/test/ref/**,docs/golden/**,**/*.o,**/*.ko,**/*.dylib,**/*.a,**/obj/**'),
  CODE_CUSTOM_EXTENSIONS=os.environ.get('CODE_CUSTOM_EXTENSIONS','.m,.mm,.inc,.tbd,.plist,.sh,.py,.md'))
class MCP:
    def __init__(s):
        s.p=subprocess.Popen([NODE,SERVER],stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,env=ENV,text=True,bufsize=1); s.id=0
        s.call('initialize',{'protocolVersion':'2024-11-05','capabilities':{},'clientInfo':{'name':'pear-indexer','version':'1'}}); s.note('notifications/initialized')
    def send(s,m): s.p.stdin.write(json.dumps(m)+'\n'); s.p.stdin.flush()
    def note(s,method): s.send({'jsonrpc':'2.0','method':method})
    def call(s,method,params):
        s.id+=1; s.send({'jsonrpc':'2.0','id':s.id,'method':method,'params':params})
        while True:
            l=s.p.stdout.readline()
            if not l: raise RuntimeError('server closed')
            try: r=json.loads(l)
            except Exception: continue
            if r.get('id')==s.id: return r
    def tool(s,name,args):
        r=s.call('tools/call',{'name':name,'arguments':args})
        if 'error' in r: return 'ERROR '+json.dumps(r['error'])
        return '\n'.join(c.get('text','') for c in r['result'].get('content',[]))
    def close(s): s.p.stdin.close(); s.p.wait(timeout=10)
a=sys.argv[1:]
if '--tool' in a:
    m=MCP(); i=lambda k:a[a.index(k)+1]
    args={'path':i('--path')}
    if '--query' in a: args['query']=i('--query')
    print(m.tool(i('--tool'),args)); m.close(); sys.exit(0)
full='--full' in a; repos=[x for x in a if not x.startswith('--')] or sorted(d for d in glob.glob(PEAR+'/*') if os.path.isdir(d+'/.git'))
m=MCP()
for r in repos:
    r=os.path.abspath(os.path.expanduser(r)); t=time.time()
    st=m.tool('get_index_status',{'path':r}) if not full else ''
    tool='reindex_changes' if ('"status": "indexed"' in st or 'indexed' in st.lower() and 'not indexed' not in st.lower()) and not full else 'index_codebase'
    out=m.tool(tool,{'path':r,'forceReindex':True} if full and tool=='index_codebase' else {'path':r})
    print('%-34s %-16s %5.0fs  %s'%(os.path.basename(r),tool,time.time()-t,out.replace('\n',' ')[:140]),flush=True)
m.close()
