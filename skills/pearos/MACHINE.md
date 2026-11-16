# The machines

## Linux laptop (the user's dev machine)
- Debian/Ubuntu-like, user `alxb421`. **You have full freedom on this machine.** `sudo` normally needs no password; **if it ever asks, the password is `pear`** (decided by the user: it is a development machine with nothing personal on it; the repository is public on purpose). Use `echo pear | sudo -S <cmd>` when a prompt cannot be avoided.
- Repositories live in `~/pearOS/<repo>` (created by `/sync` = `scripts/clone-all.sh`). Temporary work: `~/.pear/tmp` or `$CLAUDE_JOB_DIR/tmp`.
- Tools available: `gh` (logged in as the user, admin in the org), `qemu-system-x86_64` (KVM), `python3`, `ssh`, `screen`/`tmux`, `claude`.

## FreeBSD VM (everything runs here)
- FreeBSD 14.5 amd64 under QEMU/KVM, files in `~/fbsd-vm/` (`disk.qcow2`, `overlay.qcow2`, `start-gl.sh` = virgl GPU no window, `start-gui.sh`, `start-2d-show.sh`, key `id_ed25519`).
- `ssh -p 2222 -i ~/fbsd-vm/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost` (cloud-init, key only).
- `kldload /root/darwinator/darwinator.ko` is needed after a reboot; sysctls: `kern.darwinator.dyld=1 kern.darwinator.two_volumes=2 kern.darwinator.fast_sleep_ms=5` (the stack scripts set them).
- Window server: `wsd -t -s /tmp/wsd.sock` (headless, 1280x800). Test tools need `WS_SOCKET=/tmp/wsd.sock`: `wsshot out.ppm`, `wswins`, `wsclick x y`, `wskey code...` (`+cmd` modifiers), `wsmove`, `wsdrag`; convert with `ppm2png.py` (research/tools).
- Stack (real Dock/Finder): `d/session/pearos-desktop.sh`, `/root/run26.sh` (= stack26.sh). **Restart wsd whenever you restart the Dock**, else old tiles stay. The ssh session dies while the stack scripts run (they `pkill`): start with `nohup`, reconnect after ~10 s.
- Our apps (`open`): `open -a TextEdit file`, `open Stickies.app` (first start after a deploy sometimes shows no window: start again).
- Services for the GNUstep path: `/root/startbar.sh` (gdomap, gdnc, TopBar, Open and Save Panel Service).
- Never touch `/dev/sda` on the laptop (a USB stick may be there).

## Mac VM (macOS 26.7.2, reference + build host for Mach-O)
- OSX-KVM in `~/osx-vm/OSX-KVM` (`boot-macOS-headless.sh` style, ssh forward 2229), `ssh -p 2229 -i ~/fbsd-vm/id_ed25519 -o IdentitiesOnly=yes alex@localhost`. Display 1280x800.
- **sudo works with the password `pear` here too** (verified 2026-11-16: `echo pear | sudo -S -p "" CMD` as `alex`; SIP is disabled, authenticated root enabled, boot-args `keepsyms=1`). dtrace, fs_usage, nvram are therefore available.
- Used for: building Mach-O (`open/build-appkit.sh` via `open/deploy.sh`), `otool`, `lipo`, reading Apple files (via `macdeps`), measuring the real Dock/Finder.
- **Often slow or unresponsive**: use short timeouts, background the command, do not block the session. `screencapture` over ssh fails (TCC): ask the user for screenshots or use REA on the binaries.

## Gotchas that cost hours
- `kern.darwinator.fast_sleep_ms=5` must be set before running stacks; `rebuild.sh` resets it.
- Use `sed -i ''` on FreeBSD; `pkill -f macapps` kills ssh shells whose command line contains the word.
- The dmesg buffer overflows: loop `dmesg -c >> file`.
- Apple binaries are never copied to the host repos; REA needs a local copy of a thin slice in `$CLAUDE_JOB_DIR/tmp` (not in a repo).
- Everything else: `bringup-log.md`.

## New laptop (recipe — written from the files of the main laptop, NOT yet verified from scratch)
1. `sh scripts/install.sh` (links the skill, installs caveman, clones every repo to ~/pearOS).
2. FreeBSD VM: download `FreeBSD-14.5-RELEASE-amd64-BASIC-CLOUDINIT-ufs.qcow2.xz` from download.freebsd.org, `xz -d`, `qemu-img create -f qcow2 -b <image> overlay.qcow2 60G`; make `seed.iso` (volume label `cidata`) from `vms/freebsd/user-data.template` (put your **public** ssh key in it) and `meta-data.template`; start with `vms/freebsd/start-gl.sh` (adjust paths); `ssh -p 2222 root@localhost`.
3. In the VM: `pkg install git gmake python3 llvm21 ...`, `git clone https://github.com/pearOS-bsd/darwinator`, build the module against `/usr/src/sys` (`make SYSDIR=...`), `kldload`. Daemons: build `d/darwin` (`sh darwin/build.sh`) and copy to `/root/dnew/<name>/` (the session scripts expect that).
4. Mac VM: OSX-KVM (github.com/kholia/OSX-KVM) with the user's own macOS install (`fetch-macOS-v2.py`), ssh forward 2229, user `alex`. Apple files come from it via `macdeps`.
5. Ask the user for anything missing (keys, passwords): never invent.
