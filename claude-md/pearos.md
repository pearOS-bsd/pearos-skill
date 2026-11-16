# pearOS BSD (always-on summary; details: the `pearos` skill, `/status`)
Project: Mac-style desktop on FreeBSD that runs real Mac apps. Org github.com/pearOS-bsd (~55 repos, clones in ~/pearOS). Our code: BSD-2-Clause. Start every session: read the skill `pearos` (STATE.md, RULES.md) or run `/status`.

## Layers (a lower layer never depends on a higher one; put code in the LOWEST layer that can own it)
0 kernel/ABI: `darwinator`, `IOKit` · 1 runtime/loader: `dyld`, `macdeps`, `libsystem`, `libdispatch`, `libobjc`, `libcxx`, `libxpc`, `swift-runtime`, `thirdparty` · 2 core frameworks: `CoreFoundation`, `Foundation`, `CoreGraphics`, `CoreText`, `ImageIO`, `Security`, `SystemConfiguration`, `CFNetwork`, `CoreServices`, `IconServices`, `LaunchServices`, `CoreUI`, `SDK` · 3 UI/windowing: `SkyLight`→`WindowServer`, `QuartzCore`, `Solarium`, `UIFoundation`, `HIToolbox`, `AppKit`, `open` · 4 daemons/apps: `d`, `apps` · tooling: `iso`, `tests`, `docs`, `research`, `pearos-skill`, `codemap`.

## Rules that must never be forgotten
1. Nothing about Claude in commits (no Co-Authored-By, no Claude trailer/URL); never add Claude to contributors. Small commits, push every step.
2. Licences: never copy GPL/LGPL; Apple files never in repos (taken from the user's Mac by macdeps); upstream code only into `upstream/` with PROVENANCE.md.
3. Before writing ANY utility/wrapper/component: search the code index (`python3 scripts/qdrant-search.py "..."` across all repos, or Qdrant MCP `search_code`) AND `sh scripts/where-is.sh <name>`; reuse if it exists. The index lags: after edits run `python3 scripts/qdrant-wait.py <repo>` before trusting a search.
4. Do exactly what Apple does (decompile with rea/Ghidra, Apple open source, observe the Mac VM); record evidence. If unknown, ask.
5. Test on the FreeBSD VM (ssh -p 2222 root@localhost, key ~/fbsd-vm/id_ed25519); prepare CI for every piece of work; update docs and the skill every time.
6. Answer the user in Romanian, short; code/commits/docs in English. Caveman style for long autonomous runs (never in commits/docs). Linux laptop: full freedom, sudo password `pear` if asked.
