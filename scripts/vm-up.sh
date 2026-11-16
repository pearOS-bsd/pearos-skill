#!/bin/sh
# Start the FreeBSD VM headless (virgl GPU, no window) if it is not running; wait for ssh.
if ! pgrep -f "hostfwd=tcp::2222" >/dev/null; then
	[ -x "$HOME/fbsd-vm/start-gl.sh" ] || { echo "no ~/fbsd-vm/start-gl.sh: see MACHINE.md (New laptop)"; exit 1; }
	(cd "$HOME/fbsd-vm" && setsid nohup sh ./start-gl.sh >qemu.out 2>&1 &)
fi
K="-i $HOME/fbsd-vm/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q -o ConnectTimeout=5"
for i in $(seq 1 60); do ssh -p 2222 $K root@localhost true 2>/dev/null && { echo "FreeBSD VM up"; exit 0; }; sleep 5; done; echo "FreeBSD VM did not answer in 5 minutes"; exit 1
