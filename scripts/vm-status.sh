#!/bin/sh
# Is the FreeBSD VM (ssh 2222) and the Mac VM (ssh 2229) up?  Short timeouts: the Mac VM is often slow.
K="-i $HOME/fbsd-vm/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes -o BatchMode=yes -q -o ConnectTimeout=8"
echo "== FreeBSD VM (2222)"; timeout 20 ssh -p 2222 $K root@localhost 'uname -sr; kldstat | grep -c darwinator | sed "s/^/darwinator loaded: /"; pgrep -x WindowServer >/dev/null && echo "WindowServer: up" || echo "WindowServer: down"; ls /tmp/WindowServer.sock 2>/dev/null' || echo "down (sh scripts/vm-up.sh)"
echo "== Mac VM (2229)"; timeout 25 ssh -p 2229 $K alex@localhost 'sw_vers -productVersion' || echo "no answer (slow or down: do not wait for it)"
