#!/usr/bin/env python3
"""Fixed accuracy test of the code index.  python3 scripts/qdrant-eval.py [-v]
Each case: a question and the file that must be found.  Prints top-1 / top-5 hit rates; run it after every change to the index (chunk size, hybrid search, ignores)
and write the numbers next to the change in STATE.md.  A case counts as hit when the expected path is a substring of the result path.
Add cases when you find a question the index answers badly (the expected file must be one a human would open first)."""
import subprocess,sys,os
H=os.path.dirname(os.path.abspath(__file__))
CASES=[
("launchd bootstrap lookup of a service by name","d/darwin/launchd/launchd.c"),
("allocate a mach port in the kernel module","darwinator/src/mach_ipc.c"),
("add a window to the server and give it an id","WindowServer/src/server.c"),
("create window wire reply structure offsets","SkyLight/include/sls_wire.h"),
("CATransaction begin commit flush","QuartzCore/src/CATransaction.m"),
("load a nib and connect outlets","AppKit/decompiled/src/OpenNib.m"),
("save panel and open panel service","AppKit/decompiled/src/OpenFilePanels.m"),
("dock layout of tiles and magnification","apps/dock/dock_layout.h"),
("how to convert a plist to binary","iso/tools"),
("licence audit of libraries loaded by a binary","iso/licenses/audit.sh"),
("dyld shared cache extraction from the Mac","macdeps"),
("which services the Dock asks for","docs/development/DOCK-SERVICES.md"),
("region union and damage tracking","WindowServer/src/region.c"),
("evdev keyboard and touchpad input","WindowServer/src/evdev.c"),
("run the FreeBSD VM and the stack","pearos-skill/scripts/vm-up.sh"),
("shared memory buffer anonymous","WindowServer/src/buffer.c"),
]
v='-v' in sys.argv; t1=t5=0
for q,exp in CASES:
    out=subprocess.run([sys.executable,H+'/qdrant-search.py',q,'-n','5'],capture_output=True,text=True).stdout.strip().split('\n')
    files=[l.split()[1].rsplit(':',1)[0] for l in out if l.strip()]
    h=[exp in f for f in files]; a=bool(h and h[0]); b=any(h); t1+=a; t5+=b
    if v or not a: print(('1' if a else '5' if b else '-'),q[:50],'->',files[0] if files else '?')
print(f'top1 {t1}/{len(CASES)}  top5 {t5}/{len(CASES)}   (baseline 2026-11-16: top1 6/16, top5 11/16)')
