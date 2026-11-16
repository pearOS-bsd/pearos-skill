---
description: pearOS status in 20 lines: active task, next, blocked, repo/VM health
---
Load the `pearos` skill. Print (Romanian, short): ACTIVE and Next from STATE.md; open Questions; `git status -sb` + unpushed commits for each repo in ~/pearOS (use `sh scripts/clone-all.sh --status`); whether the FreeBSD VM answers (`ssh -p 2222 ... uptime`) and whether wsd runs there; the last CI run per repo if `gh` is logged in.
