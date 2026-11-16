# Doing exactly what Apple does

Order of evidence (stop at the first that answers):
1. **Apple open source** (github.com/apple-oss-distributions: xnu, Libc, libdispatch, objc4, CF, configd, IOKitUser, dyld, Security ...): read the real code.
2. **The binary** on the Mac VM / dyld cache: decompile with rea/Ghidra (`TOOLS.md`): symbols are kept (`DockBar::`, `DOCKTileLayer::` ...). Read constants with `read_bytes`, selectors with `search_strings`, behaviour with `procedure_pseudo_code`.
3. **Observation on the Mac VM**: `defaults read`, `otool`, `plutil`, `log`, behaviour of the real app; screenshots need the user (TCC blocks `screencapture` over ssh).
4. **Documentation / headers** (public SDK docs) — last, they lie by omission.
Then: implement the **behaviour** (numbers, order of calls, defaults, error codes), not Apple's code (unless it is open source under a licence we accept).
Record: `docs/development/APPLE-DECISIONS.md` — one entry per decision: question · what Apple does · evidence (binary, address/symbol, command) · what we implemented · date. Dock numbers are in `DOCK-DECOMPILED.md`.
If nothing answers: write the question in `STATE.md` "Questions" and ask the user; do not invent silently.
