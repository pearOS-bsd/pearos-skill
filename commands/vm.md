---
description: Start or check the FreeBSD and Mac VMs and the pearOS stack
---
Run `sh scripts/vm-status.sh` (ports 2222 FreeBSD, 2229 Mac). If the FreeBSD VM is down: `sh scripts/vm-up.sh` (uses ~/fbsd-vm/start-gl.sh; waits for ssh). Then check `kldstat | grep darwinator` (kldload if missing), that WindowServer runs, and report. The Mac VM is slow: short timeouts, never block on it. If the VMs do not exist on this laptop, say so and read MACHINE.md → "New laptop" before inventing anything.
