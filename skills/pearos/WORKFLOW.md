# Workflow (what `/work` does)

## The loop
0. **Orient**: read `STATE.md`, `RULES.md`; `git pull` the repos you will touch; make sure the VM answers (`/vm`).
1. **Pick the task**: the argument of `/work`, else the first item of "Next" in `STATE.md`. Write it at the top of `STATE.md` under "Active" with a definition of done (what must run, on the VM, to call it finished).
2. **Search first** (RULES 7, 16): the Qdrant index (`search_code`) and `scripts/search-first.sh`; read what already exists; decide *reuse / adapt / write*. Note the finding.
3. **Apple first** (RULES 8): if the task has a Mac counterpart, find Apple's real behaviour (`APPLE.md`) before designing.
4. **Small step**: implement the smallest useful piece, in the right repository. Keep builds working (the iso workspace layout, `*_DIR` variables).
5. **Test on the VM**: build, run, screenshot / log / test output. Fix until it works or until blocked (then record the blocker in `STATE.md`).
6. **CI/CD**: add or update the workflow of that repository so the new thing is built and tested automatically.
7. **Docs and skill**: update the repo README, `pearOS-bsd/docs`, and `STATE.md` / `PROJECT.md` of this skill. Commit docs with the code.
8. **Commit + push** (no Claude trailer). One logical change per commit. Then `python3 scripts/qdrant-wait.py <repo>` so the index (and the 3D map) follow the change (RULES 17).
9. **Decide**: done? → mark done in `STATE.md`, summarise for the user, stop the loop. Not done → schedule the next tick (`ScheduleWakeup`, 20–30 min) with the same prompt and continue from step 4. Blocked on the user → write the question in `STATE.md` ("Questions"), notify, stop.

## Definition of done
Runs on the FreeBSD VM · tests/CI added · licences respected (audit passes) · docs + skill updated · pushed · nothing unverified claimed as verified.

## Overnight
`/work` starts the dynamic loop. `/night` starts `scripts/night.sh` in `screen`/`tmux` so that after a usage limit the work resumes at the reset time on its own. Both stop when `STATE.md` has the line `ACTIVE: none` or the active task says `STATE: DONE`.

## Checklists
**CI/CD**: workflow file in `.github/workflows/`; build step; test step (FreeBSD VM action for kernel/userland; macOS runner for Mach-O builds); artifacts (screenshots/logs); runs on push and PR.
**Docs**: README of the repo (what, build, test), `docs/development/*` for design decisions and measured numbers, `docs/` user pages if user-visible, `REPOS.md` if a repo appeared/changed, this skill's `STATE.md`.
