# Tools (use them; do not do by hand what they do)

## caveman
Terse-output skill (JuliusBrussee/caveman): ~half the output tokens for long autonomous runs.
- Install: `claude plugin marketplace add JuliusBrussee/caveman && claude plugin install caveman@caveman` (done by `scripts/install.sh`).
- Use it in `/work` and overnight loops. Never for commit messages, docs, code, or decisions explained to the user. `/caveman-stats`, `/caveman-compress` exist.

## rea (MCP) and Ghidra — reverse engineering
- `rea` is an MCP server (tools `mcp__rea__*`); its provider for Mach-O is **Ghidra 12.x** (headless, needs a JVM). Load the tools with ToolSearch (`select:mcp__rea__open_binary,mcp__rea__procedure_pseudo_code,...`).
- Flow: copy a **thin x86_64 slice** of the Apple binary into `$CLAUDE_JOB_DIR/tmp` (never into a repo): `python3` fat-header cut (see bringup-log "Dock decompile") → `open_binary path` → `search_procedures pattern (mode: regex, detail: summary|complete)` → `procedure_pseudo_code procedure=NAME` / `procedure_assembly` / `read_bytes address length` / `search_strings` / `xrefs`.
- Big results are saved to a file: filter with python/jq, do not paste them. Ghidra needs ~minutes to analyse a 5 MB binary the first time (`search_*` may be moved to background: wait for the notification).
- Use it to answer "what exactly does Apple do?" (see `APPLE.md`), to read selectors/ivars, and to compare with our implementation. Record numbers in `docs/development/DOCK-DECOMPILED.md`-style notes.

## gh
`gh repo create pearOS-bsd/NAME --public`, `gh search code|repos`, `gh api`. The user is **admin** of the org.

## Scheduler (loops and timers)
- `ScheduleWakeup` (dynamic /loop, 60–3600 s) re-enters a prompt later; pass the same prompt back each tick.
- `CronCreate` for fixed intervals (session cron, expires after 7 days).
- Usage limit: a running Claude session cannot work past the limit. `scripts/night.sh` runs outside Claude and restarts `claude -p --continue "/work resume"` after the limit resets (see `/night`).

## Search-first helper
`sh scripts/search-first.sh "<keywords>"` searches our repos (local clones), the org on GitHub, apple-oss-distributions and the known projects, and prints candidates with licences.

## Existing helpers in the repos
`open/deploy.sh [program]` (build on Mac VM + install on FreeBSD VM + screenshot), `tests/smoke/smoke.sh`, `iso/licenses/audit.sh`, `macdeps/macdeps.sh`, `d/session/*`.
