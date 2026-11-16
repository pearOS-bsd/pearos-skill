# pearos-skill

A [Claude Code](https://code.claude.com) skill + commands for the **pearOS BSD** project, so that a session on **any laptop** starts at full speed: the project map, the rules, the current state, the machines, the tools — and `/work`, an unattended loop that works on a task through the night.

## Install (60 seconds)
```sh
git clone https://github.com/pearOS-bsd/pearos-skill
sh pearos-skill/scripts/install.sh      # links skill + commands into ~/.claude, installs caveman, clones every pearOS repo to ~/pearOS
cd ~/pearOS && claude                    # then: /status    or    /work <task>
```
Plugin alternative: `/plugin marketplace add pearOS-bsd/pearos-skill` then `/plugin install pearos@pearos-skill` (commands become `/pearos:work` ...).

## Commands
| | |
|---|---|
| `/work [task]` | unattended loop: search first → what Apple does → small step → test on the VM → CI → docs → commit → repeat |
| `/status` | active task, next steps, repo and VM health |
| `/sync` | clone/update every repository |
| `/vm` | start/check the FreeBSD and Mac VMs |
| `/night` | watchdog that resumes `/work` after a Claude usage limit resets |
| `/apple <question>` | what Apple really does, with evidence, recorded |
| `/audit` | licence audit |
| `/docs` | update docs and this skill |

## What is inside
`skills/pearos/`: `SKILL.md` (entry), `PROJECT.md` (every repository), `STATE.md` (done/next/decisions — updated all the time), `RULES.md`, `MACHINE.md`, `TOOLS.md`, `WORKFLOW.md`, `APPLE.md`, `bringup-log.md`.
`commands/`, `scripts/` (`install.sh clone-all.sh night.sh search-first.sh vm-up.sh vm-status.sh`), `vms/freebsd/` (VM start scripts and cloud-init templates).

Secrets (sudo password, keys) live in `~/.pear/` on each machine and are **never** committed.
Licence: BSD-2-Clause.
