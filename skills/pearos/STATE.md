# State of the project (update at every milestone; last: 2026-11-16)

ACTIVE: none

## Done (highlights)
- Mac programs run on FreeBSD: `darwinator` (module) + real dyld; real Dock + real IconServices icons draw on wsd; real Finder alive (details: bringup-log.md).
- `open` layer: our AppKit on wsd runs real **TextEdit** (typing, menus, ⌘A/C/V/S, edited marker, Open/Save panel service) and **Stickies** (yellow note, typing). pearOS-style decorations/menus/controls.
- Repo reorganisation done: ~40 repos in github.com/pearOS-bsd, all public, `misc` emptied. `iso/build.sh` assembles a workspace from the repos (copies in the old wsbsd layout). Licence: BSD-2-Clause LICENSE+NOTICE in our repos.
- Survey of existing projects + licence rules (docs/development/EXISTING-PROJECTS.md, LICENSES.md); upstream sources copied into `upstream/` of: libsystem, libdispatch, libobjc, libxpc, CoreFoundation, Foundation, CoreGraphics, CoreText, CoreServices, Security, SystemConfiguration, CFNetwork, HIToolbox, IOKit, QuartzCore.
- Licence audit `iso/licenses/audit.sh` exists.

## Next (in this order unless the user says otherwise)
1. **GPL libraries in the GNUstep-path binaries** (FFmpeg/x264/x265/libdvdnav/libao via gnustep pkgs): build GNUstep without them or retire the path; make `audit.sh` pass.
2. **Verify the full ISO build** (`iso/build.sh`) and the CI of the new repos (WindowServer, iso, ...): nothing of it has run on GitHub yet.
3. **Dock 1:1 with macOS** (our Dock in `apps/dock`): services first (cfprefsd, LaunchServices, IconServices in `d/session`), then Dock as Mach-O client on `open`, then look from the decompile (`docs/development/DOCK-DECOMPILED.md`, `DOCK-SERVICES.md`), then boot integration (Dock + Finder in startbar, default wallpaper, active-app menu in the bar). Real Dock gets no mouse events (WSD_MAC_DG=1 breaks it): needs HID/event path.
4. **`open`**: Save of a new RTF document (TextEdit fileWrapperOfType error 66062), Undo/Redo, caret/selection with arrows, Stickies buttons/spine/RTFD, Chess, Calculator, Terminal, Dictionary, third-party apps; services started on demand + README; Window menu in the bar.
5. **dyld from source** (`dyld` repo: fork apple-oss-distributions/dyld tag dyld-1378, build on the Mac VM with Xcode; the 5 GB cache stays from the user's Mac — it cannot be generated from the open source).
6. **Cache of our own** (docs/development/CACHE-LIBRARIES.md): start with libsystem family, libdispatch, libobjc (all open at Apple).
7. Move leftovers: `research` raw dumps policy, retire GNUstep-era code (`AppKit/back-wsd`, most of `SDK/src`, `iso/ci/gnustep-*.sh`, `ports/`).

## Blocked / waiting for the user
- `CoreGlyphs` Assets.car (105 MB): the user's xz was 1 KB (empty); needs the real file or a download from the Mac.
- Mac VM ssh is often unresponsive.

## Decisions taken
- Final licence: BSD-2-Clause (holder text "pearOS-bsd contributors", changeable). GPL/LGPL code is not copied; GNUstep libs are LGPL (checked on sources: base/gui/back/corebase/opal/quartzcore), dynamic linking only; APSL files stay APSL; Apple binaries never distributed.
- `.car` files in CoreUI are public: the user says they were recreated, not Apple's originals — leave as is.
- SystemUIServer is an app (lives in `apps/topbar`), no own repo; Dock/Finder/loginwindow also in `apps`.
- No Claude co-author/trailer in commits (user rule, 2026-11-16).

## Questions for the user (ask at the next chance)
- Keep the `Claude-Session:` trailer in commits? (default: drop it.)
- Should `/work` use `--dangerously-skip-permissions` in the headless watchdog? (default: no, use an allow-list.)
- Where is the real SF Symbols `CoreGlyphs` Assets.car?
- Does the other laptop have the VMs? (`/sync` and `/vm` assume the FreeBSD VM can be started; recipe for new laptops is TODO.)
