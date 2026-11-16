# Rules (not optional)

## Git and attribution
1. **No "Co-Authored-By: Claude"** (or any Claude/Anthropic trailer) in commit messages. Do not add Claude to contributors, AUTHORS, README credits or CODEOWNERS. Commits are authored by the user's own git identity.
2. Commit **small steps** and **push at every step** to the repository concerned (commit message: what and why, in English). Never force-push or rewrite pushed history without the user's explicit OK.
3. Temporary files go in `$CLAUDE_JOB_DIR/tmp` (or `~/.pear/tmp`), never in `/tmp` shared paths and never in a repository.

## Licences (see docs/development/LICENSES.md)
4. Our code is **BSD-2-Clause**. Copy code from other projects only if the licence allows (MIT/BSD/ISC/Apache/APSL) into `upstream/` with licence files kept and `PROVENANCE.md` updated. **Never copy GPL / LGPL code** (Darling, GNUstep): read it only.
5. **Never put Apple files in a repository** (dyld cache, system binaries, frameworks). They stay on the VMs / the user's Mac and are fetched by `macdeps`. Decompile **outputs we write ourselves** (notes, numbers) are fine; raw dumps need a second thought — ask.
6. Run `iso/licenses/audit.sh` before anything that goes into the image. No GPL library may be loaded by a shipped binary.

## Work quality
7. **Search first, do not reinvent the wheel.** Before writing anything: look in our repos, in `upstream/` folders, on GitHub (`gh search code/repos`), in apple-oss-distributions, ravynOS, NextBSD, Cocotron, swift-corelibs. Only build what does not exist; record what you found in the commit or the docs.
8. **Do exactly what Apple does.** When a behaviour or a design choice exists on the Mac, find Apple's real answer (decompile with rea/ghidra, observe on the Mac VM, Apple open source) and copy the *behaviour*. Write the evidence in `docs/development/APPLE-DECISIONS.md` (see `APPLE.md`). If it cannot be found, ask the user — do not guess silently.
9. **Test on the VM** (FreeBSD VM for everything that runs; Mac VM only to compare/measure). A change is not done until it ran on the VM. Screenshots with `wsshot`.
10. **Prepare CI/CD for every piece of work**: a workflow that builds and tests it (GitHub Actions, FreeBSD VM action where needed), added or updated in the same change.
11. **Update the docs every time** (`pearOS-bsd/docs` and the README of the repo you touched) **and update this skill** (`STATE.md` at least; `PROJECT.md` when a repo changes; `RULES.md` when a rule is decided). A task that changed behaviour and not the docs is not finished.
12. Prefer many small verified steps over big unverified ones; report what was **not** verified honestly.

## Talking
13. The user speaks **Romanian**: answer in Romanian, short and concrete. Code, commits, docs and READMEs in English (simple words in public-facing text).
14. Use **caveman** mode for long autonomous work to save tokens (see TOOLS.md) — never in commit messages, docs, code or when explaining a decision to the user.
15. Ask the user when a decision is theirs (licence, naming, deleting/rewriting public things, money, anything irreversible and outward-facing). Otherwise decide and go.
