---
description: Index or re-index the whole pearOS project into the local Qdrant (semantic code search), and wait until it is in sync
argument-hint: "[repo-path ... | --full]"
---
Run `python3 scripts/qdrant-index.py $ARGUMENTS` from the skill folder (no LLM tokens: it talks to the MCP server directly), then `python3 scripts/qdrant-wait.py` and report the numbers (points per collection). First time: `sh scripts/qdrant-setup.sh`. After large edits use this instead of trusting the index. Then refresh the 3D map: `sh scripts/map-publish.sh` if it exists.
