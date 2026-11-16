# State of the project (update at every milestone; last: 2026-11-16)

ACTIVE: none

## Done (highlights)
- Mac programs run on FreeBSD: `darwinator` (module) + real dyld; real Dock + real IconServices icons draw on wsd; real Finder alive (details: bringup-log.md).
- `open` layer: our AppKit on wsd runs real **TextEdit** (typing, menus, ⌘A/C/V/S, edited marker, Open/Save panel service) and **Stickies** (yellow note, typing). pearOS-style decorations/menus/controls.
- Repo reorganisation done: ~40 repos in github.com/pearOS-bsd, all public, `misc` emptied. `iso/build.sh` assembles a workspace from the repos (copies in the old wsbsd layout). Licence: BSD-2-Clause LICENSE+NOTICE in our repos.
- Survey of existing projects + licence rules (docs/development/EXISTING-PROJECTS.md, LICENSES.md); upstream sources copied into `upstream/` of: libsystem, libdispatch, libobjc, libxpc, CoreFoundation, Foundation, CoreGraphics, CoreText, CoreServices, Security, SystemConfiguration, CFNetwork, HIToolbox, IOKit, QuartzCore.
- Licence audit `iso/licenses/audit.sh` exists (run it with the ROOT of the image, `sh audit.sh /path/to/tree`: without an argument it audits the Linux laptop).
- **Code index (2026-11-16)**: local Qdrant + Ollama (jina-embeddings-v2-base-code) + MCP; 40 collections, 5 243 points, no `upstream/` in it; `python3 scripts/qdrant-search.py` searches all repos (0.25 s), `where-is.sh` for exact names; 3D map live at https://pearos-bsd.github.io/codemap/; watcher in `screen -S pearindex`. Docs: `docs/development/CODE-INDEX.md`. The MCP server needs `patches/mcp-env-ignore.py` (see TOOLS.md).
- **CI**: every repo with code calls the shared `hygiene` workflow (`pearOS-bsd/.github`: no Claude in commits, no Apple binaries, README/LICENSE/NOTICE, shell/python/yaml syntax). WindowServer and darwinator build+test green on GitHub (fixed: includes in `sls_window.c`, `machine/segments.h` only on amd64, CoreUI path in the Makefile). darwinator arm64 is experimental (`continue-on-error`): the workqueue/syscall code uses x86 registers, the arm64 port has not started.

## Next (in this order unless the user says otherwise)
1. **GPL libraries in the GNUstep-path binaries** (FFmpeg/x264/x265/libdvdnav/libao via gnustep pkgs): build GNUstep without them or retire the path; make `audit.sh` pass.
2. **Verify the full ISO build** (`iso/build.sh` passes `bash -n`, the whole build has not run since the repo split); `iso` CI exists, WindowServer/darwinator CI is green.
2b. **Golden deviations** (WindowServer `test/test_golden.c` `known_deviation`): 30001 SetUniversalOwner and 30445 ReserveStructuralRegionIDRange differ from the 26.6.2 recording, not yet checked on the Mac VM; 30553 follows the 26.7.2 SkyLight on purpose. Resolve against the Mac, then remove from the list.
2c. RenderBox (private, closed, SwiftUI's renderer) is loaded by the real Dock through the cache; unverified on FreeBSD (needs Metal). QuartzCore coverage vs the macOS API has not been counted.
3. **Dock 1:1 with macOS** (our Dock in `apps/dock`): services first (cfprefsd, LaunchServices, IconServices in `d/session`), then Dock as Mach-O client on `open`, then look from the decompile (`docs/development/DOCK-DECOMPILED.md`, `DOCK-SERVICES.md`), then boot integration (Dock + Finder in startbar, default wallpaper, active-app menu in the bar). Real Dock gets no mouse events (WSD_MAC_DG=1 breaks it): needs HID/event path.
4. **`open`**: Save of a new RTF document (TextEdit fileWrapperOfType error 66062), Undo/Redo, caret/selection with arrows, Stickies buttons/spine/RTFD, Chess, Calculator, Terminal, Dictionary, third-party apps; services started on demand + README; Window menu in the bar.
5. **dyld from source** (`dyld` repo: fork apple-oss-distributions/dyld tag dyld-1378, build on the Mac VM with Xcode; the 5 GB cache stays from the user's Mac — it cannot be generated from the open source).
6. **Cache of our own** (docs/development/CACHE-LIBRARIES.md): start with libsystem family, libdispatch, libobjc (all open at Apple).
7. Move leftovers: `research` raw dumps policy, retire GNUstep-era code (`AppKit/back-wsd`, most of `SDK/src`, `iso/ci/gnustep-*.sh`, `ports/`).

## Blocked / waiting for the user
- Mac VM ssh is often unresponsive.
- `CoreGlyphs` (SF Symbols 105 MB Assets.car): set aside, the user handles it on 2026-11-17.

## Decisions taken
- Final licence: BSD-2-Clause (holder text "pearOS-bsd contributors", changeable). GPL/LGPL code is not copied; GNUstep libs are LGPL (checked on sources: base/gui/back/corebase/opal/quartzcore), dynamic linking only; APSL files stay APSL; Apple binaries never distributed.
- `.car` files in CoreUI are public: the user says they were recreated, not Apple's originals — leave as is.
- SystemUIServer is an app (lives in `apps/topbar`), no own repo; Dock/Finder/loginwindow also in `apps`.
- Nothing about Claude in commits: history of every org repo rewritten (force-pushed) on 2026-11-16 to drop `Claude-Session:` trailers; backups in the bundle files of that night's session only. Clones made before that must `git fetch && git reset --hard origin/<branch>`.
- Sudo password of the Linux dev laptop is `pear`, written in the (public) repo on purpose. Headless overnight runs use `--dangerously-skip-permissions`. Caveman = the JuliusBrussee/caveman skill. REA is installed by its own guide. The other laptop may or may not have the VMs: ask when missing.

## Questions for the user
- (none open)
