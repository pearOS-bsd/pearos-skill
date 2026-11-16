---
name: pearos
description: Use for ANY work on pearOS BSD (github.com/pearOS-bsd: darwinator, dyld, d, WindowServer, SkyLight, AppKit, open, QuartzCore, CoreUI, SDK, apps, iso, docs ...): a Mac-style desktop on FreeBSD that runs real Mac apps. Loads the project map, the rules, the current state, the machine/VM facts and the tools (rea, ghidra, caveman). Read it first in every pearOS session, before touching code.
---

# pearOS BSD — start here

You are continuing a long project. Do not start from zero and do not reinvent: everything you need to begin is in this folder.

## First 60 seconds of every session
1. Read `STATE.md` (what is done, what is next, open decisions).
2. Read `RULES.md` (they are not optional).
3. Read `MACHINE.md` (this laptop, the two VMs, ssh, sudo) and `TOOLS.md` (rea, ghidra, caveman, loop).
4. Run `/status` (or `sh scripts/clone-all.sh` if the repositories are not on this laptop yet).
5. If the user typed a task, work on it with `WORKFLOW.md` (search first, Apple's behaviour first, test on the VM, CI, docs, commit). `/work` runs that workflow unattended.

## Files
| file | what |
|---|---|
| `PROJECT.md` | what pearOS is, what every repository does, how the pieces talk |
| `STATE.md` | done / next / blocked / decisions — update it at every milestone |
| `RULES.md` | the rules (git, licences, tests, CI, docs, language) |
| `MACHINE.md` | the Linux laptop, the FreeBSD and Mac VMs, ports, keys, sudo, gotchas |
| `TOOLS.md` | caveman, rea (MCP), ghidra, gh, the scheduler; how to use them |
| `WORKFLOW.md` | the algorithm of `/work`, definition of done, CI/CD and docs checklists |
| `APPLE.md` | how to find out exactly what Apple does, and where to record it |
| `bringup-log.md` | the long log of everything learned while bringing Mac programs up (read the part you need; it is long) |

## Commands (also in `commands/`)
`/index` index + wait for sync · `/work [task]` overnight loop · `/status` · `/sync` clone/pull all repos · `/vm` start/check the VMs · `/night` set up the usage-limit watchdog · `/apple <question>` find Apple's real behaviour · `/audit` licence audit · `/docs` update docs and this skill.

## Two sentences that matter most
Before building anything: **search whether it already exists** (our repos, GitHub, Apple's open source, ravynOS, NextBSD, Cocotron ...).
When Apple has a way of doing something: **do exactly what Apple does** (decompile / observe it, then record the evidence).
