#!/bin/sh
# Local semantic code index: Qdrant (docker) + Ollama (embeddings) + the qdrant MCP server (mhalder/qdrant-mcp-server, MIT), registered in Claude Code.  sh scripts/qdrant-setup.sh
# Model: unclemusclez/jina-embeddings-v2-base-code (768 dims, code-aware).  Everything stays on this machine (localhost only).
set -e
mkdir -p "$HOME/.pear/qdrant"
# 1. Qdrant
docker inspect qdrant >/dev/null 2>&1 || docker run -d --name qdrant --restart unless-stopped -p 127.0.0.1:6333:6333 -p 127.0.0.1:6334:6334 -v "$HOME/.pear/qdrant:/qdrant/storage" qdrant/qdrant
docker start qdrant >/dev/null 2>&1 || true
# 2. Ollama + the embedding model
command -v ollama >/dev/null 2>&1 || curl -fsSL https://ollama.com/install.sh | sh
ollama pull unclemusclez/jina-embeddings-v2-base-code
# 3. the MCP server needs Node >= 22.14
. "$HOME/.nvm/nvm.sh" 2>/dev/null && nvm install 22 >/dev/null 2>&1
NODE=$(ls "$HOME"/.nvm/versions/node/v22*/bin/node 2>/dev/null | tail -1); [ -n "$NODE" ] || NODE=$(command -v node)
[ -d "$HOME/.pear/qdrant-mcp-server" ] || git clone --depth 1 https://github.com/mhalder/qdrant-mcp-server.git "$HOME/.pear/qdrant-mcp-server"
(cd "$HOME/.pear/qdrant-mcp-server" && PATH="$(dirname "$NODE"):$PATH" npm install --no-audit --no-fund >/dev/null 2>&1 && PATH="$(dirname "$NODE"):$PATH" npm run build >/dev/null 2>&1)
# 4. register in Claude Code (user scope): tools index_codebase, search_code, reindex_changes, contextual_search, index_git_history ...
if command -v claude >/dev/null 2>&1; then
	claude mcp remove qdrant >/dev/null 2>&1 || true
	claude mcp add --scope user qdrant -e EMBEDDING_PROVIDER=ollama -e EMBEDDING_MODEL=unclemusclez/jina-embeddings-v2-base-code -e QDRANT_URL=http://localhost:6333 -e CODE_BATCH_SIZE=8 -e EMBEDDING_RETRY_ATTEMPTS=5 \
		-e "CODE_CUSTOM_IGNORE=upstream/**,catalogs/**,**/*.car,**/*.otool-ov.txt,**/*.objc.txt,**/*.dyld_info-objc.txt,docs/golden/**,**/golden/**,**/build/**" -e "CODE_CUSTOM_EXTENSIONS=.m,.mm,.inc,.tbd,.plist,.sh,.py,.md" \
		-- "$NODE" "$HOME/.pear/qdrant-mcp-server/build/index.js"
fi
echo "ready: Qdrant http://localhost:6333, Ollama, MCP 'qdrant'.  Index everything:  python3 scripts/qdrant-index.py   (about 2 hours on CPU the first time)"
