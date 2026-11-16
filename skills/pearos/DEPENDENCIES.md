# Layers and dependency direction (read before adding code)

A lower layer never depends on a higher one. Put new code in the **lowest layer that can own it**. If it needs something from a higher layer, the design is wrong: move the code down or invert the dependency (callback / protocol / IPC).

| layer | what | repositories |
|---|---|---|
| **0 kernel / ABI** | Mach IPC, syscalls, workqueues, kqueue, IORegistry on FreeBSD | `darwinator`, `IOKit` (user side) |
| **1 runtime & loader** | dyld, libSystem family, Objective-C runtime, GCD, C++ runtime, XPC | `dyld`, `macdeps`, `libsystem`, `libdispatch`, `libobjc`, `libcxx`, `libxpc`, `swift-runtime`, `thirdparty` |
| **2 core frameworks** | CoreFoundation, Foundation, CoreGraphics, CoreText, ImageIO, Security, SystemConfiguration, CFNetwork, CoreServices | `CoreFoundation`, `Foundation`, `CoreGraphics`, `CoreText`, `ImageIO`, `Security`, `SystemConfiguration`, `CFNetwork`, `CoreServices`, `IconServices`, `LaunchServices`, `CoreUI`, `SDK` |
| **3 UI & windowing** | the window protocol and server, animation, the toolkit, the launcher | `SkyLight` → `WindowServer`, `QuartzCore`, `Solarium` (Liquid Glass, above QuartzCore, below AppKit), `UIFoundation`, `HIToolbox`, `AppKit`, `open` |
| **4 daemons & apps** | services and programs on top | `d` (launchd, notifyd, wsbridge, lsd ...), `apps` (Dock, Finder, topbar, loginwindow, Terminal, TextEdit) |
| tooling | build, tests, docs, research | `iso`, `tests`, `docs`, `research`, `pearos-skill`, `codemap` |

Known edges (who uses whom): `AppKit` → `SkyLight` client + `WindowServer` client lib (`libwsclient`) + `CoreUI`; `WindowServer` → `SkyLight` (headers + handlers); `open` → `AppKit` + stubs; `d/darwin/wsbridge` → `WindowServer` socket; `apps` → `AppKit`/GNUstep path + `SDK`; `iso/build.sh` → every repo (assembles a workspace); `darwinator` → nothing above layer 0.

## Golden rule
1. **Search before writing** (RULES 16): the Qdrant index (ideas) **and** the symbol index (exact names): `sh scripts/where-is.sh <symbol>`; for a missing symbol of a Mac binary: `nm -u` / `otool -L` on the Mac VM, then `where-is.sh` on each name.
2. If it exists in a **lower** layer: use it. If it exists in the **same** layer elsewhere: reuse, do not duplicate. If it does not exist: write it in the lowest layer that can own it, reading only the header and the style of that repository (use `search_code` chunks, not whole files).
3. Vectors answer "where did we do something like this"; this file answers "who may depend on whom"; the symbol index answers "where exactly is this name". Use all three.
