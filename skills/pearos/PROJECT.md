# pearOS BSD — what it is and what every repository does

**pearOS BSD**: a Mac-style desktop on **FreeBSD** that runs **real Mac applications**.  GitHub org: https://github.com/pearOS-bsd (all public).  Final licence of our code: **BSD-2-Clause**.
Homepage: `pearOS-bsd/.github` (profile README).  Docs: `pearOS-bsd/docs` (`development/` has REPOS.md, REPO-GAPS.md, CACHE-LIBRARIES.md, EXISTING-PROJECTS.md, LICENSES.md, DOCK-*.md).

## How it works (the picture)
```
Mac app ──open──> our AppKit (/open/AppKit) ──SkyLight──> WindowServer (WindowServer) ──> FreeBSD (DRM/KMS, evdev)
   │                    │                                      ▲
   │             real Foundation, CoreFoundation, libSystem... from the Mac's dyld shared cache (taken from the USER'S OWN Mac by macdeps; never distributed)
   └── runs through the real dyld on the FreeBSD kernel module darwinator (Mach-O loader, syscalls, Mach IPC, workqueues, kqueue)
daemons (d): launchd, notifyd, wsbridge (Mac client lib <-> WindowServer), lsd (LaunchServices), carender (CA render), hid, wm ...
```
- Mac programs run **unmodified** (Mach-O) on `darwinator` + the **real dyld** (from the Mac); **AppKit is ours** (written back class by class); the window server **WindowServer** speaks the real **SkyLight** protocol.
- Older, GNUstep-based path (GNUstep + Opal + our `back-wsd`) still exists for native apps; it is being retired (it also loads GPL libraries through FFmpeg: see STATE.md).

## Repositories (github.com/pearOS-bsd/<name>)
**System layer**
| repo | what |
|---|---|
| `darwinator` | FreeBSD kernel module that runs Mach-O programs (amd64/arm64): syscalls, Mach IPC, workqueue/kqueue emulation, IORegistry nodes, fsid/getattrlist model of a Mac; its tests |
| `dyld` | loader side: `machrun` (old user-space loader), `macapp`, cache/framework tools (`fwskel.py`, `symbolize-trace.py`, MIG tools), notes on the real dyld. Plan: build dyld from apple-oss source (APSL) |
| `macdeps` | takes what Apple owns from the user's own Mac; **scripts and lists only, no Apple files** |
| `IOKit` | user-space IOKit: `hid-stub`; upstream IOKitUser, DiskArbitration |
| `d` | the daemons: `darwin/` (Mach-O: launchd, notifyd, wsbridge, lsd-stub/xpc-stub, lsd-objc, svc-stub, carender-stub, wm-stub), `bsd/` (GNUstep: launchd+agents, usernoted, airportd, Open and Save Panel Service), `session/` (scripts that start the stack: pearos-desktop.sh, stack-dock*.sh, dock-prefs) |
**Graphics / UI**
| repo | what |
|---|---|
| `WindowServer` | **WindowServer**: compositor (sw/GL), backends (KMS/fb/headless), input (evdev, touchpad, xkb), IPC, client lib (`libwsclient`), test tools (`wsshot wsclick wskey wsdrag wsmove wswins wsshow wscarender ...`), tests, CI |
| `SkyLight` | the SkyLight protocol: wire headers, ~200 server handlers (`server/sls_*.c`), client shim, generators, specs |
| `AppKit` | our AppKit: ~258 classes written back from the decompile + the backend `Open*.m` (windows, events, text, nib loader, documents, menus, panels, colours, theme); tools/ |
| `open` | `open App.app` launcher, `open-patch.py` (rewrites load commands), stub generator, `deploy.sh` (build on Mac VM, install on FreeBSD VM), `build-appkit.sh` |
| `QuartzCore` | CoreAnimation compat + reference tests + `tools/ca` (CA stream tools) |
| `CoreUI` | `.car` asset reader + `assets/`, `catalogs/` (user says these `.car` were recreated; leave public) |
| `SDK` | compat frameworks/headers for the GNUstep path (`libwsbsdcompat`, CoreWLAN/CoreWiFi, XPC.m ...), `defaults/` |
| `LaunchServices` | icons (`LSIcon`, icns), UTI table, desktop pictures |
| `apps` | Dock (ours, 1:1 with macOS is a goal), Finder, topbar (=SystemUIServer, an app), loginwindow, Terminal, TextEdit, ksa, uitest |
**Build / test / docs**
| repo | what |
|---|---|
| `iso` | builds the image: `build.sh` fetches every repo, assembles a workspace, builds; `licenses/audit.sh`; `iso.yml` workflow |
| `tests` | cross-repo tests: `smoke/smoke.sh`, open programs, darwinator app tests |
| `docs` | user + developer docs |
| `research` | decompile dumps, notes, probes, lab, legacy workflows |
| `pearos-skill` | THIS skill |
**Planned libraries for a cache of our own** (each has `upstream/` sources from other projects + PROVENANCE.md; mostly empty of our code): `libsystem libdispatch libobjc libcxx libxpc CoreFoundation Foundation CoreGraphics CoreText ImageIO UIFoundation IconServices CoreServices Security SystemConfiguration CFNetwork HIToolbox PrivateFrameworks swift-runtime thirdparty`
**Private**: `hostlib` (host library for third-party Mach-O frameworks; never named in public files).
**Not ours / earlier**: `ploader` (boot loader fork of rEFInd), `clevo_wmi`, `virtio` (virtio_gpu port), `package-repo`, `pkgbuild`, `AppStore-Backend`, `kext`, `misc` (emptied; pointer README).

## Other projects we looked at (details in docs/development/EXISTING-PROJECTS.md)
ravynOS (MIT Cocotron-based frameworks: copied to upstream/), NextBSD / nextbsd-redux (Mach IPC + launchd in the FreeBSD kernel: closest to darwinator), pkgdemon/freebsd-launchd-mach, PureDarwin/XPC, Apple open source (apple-oss-distributions), swift-corelibs, GNUstep (LGPL libs), Cocotron, Darling (GPL: read only), helloSystem, Gershwin.
