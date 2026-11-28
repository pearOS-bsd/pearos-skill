# The machines

## Linux laptop (the user's dev machine)
- Debian/Ubuntu-like, user `alxb421`. **You have full freedom on this machine.** `sudo` normally needs no password; **if it ever asks, the password is `pear`** (decided by the user: it is a development machine with nothing personal on it; the repository is public on purpose). Use `echo pear | sudo -S <cmd>` when a prompt cannot be avoided.
- Repositories live in `~/pearOS/<repo>` (created by `/sync` = `scripts/clone-all.sh`). Temporary work: `~/.pear/tmp` or `$CLAUDE_JOB_DIR/tmp`.
- Tools available: `gh` (logged in as the user, admin in the org), `qemu-system-x86_64` (KVM), `python3`, `ssh`, `screen`/`tmux`, `claude`.

## FreeBSD VM (everything runs here)
- FreeBSD 14.5 amd64 under QEMU/KVM, files in `~/fbsd-vm/` (`disk.qcow2`, `overlay.qcow2`, `start-gl.sh` = virgl GPU no window, `start-gui.sh`, `start-2d-show.sh`, key `id_ed25519`).
- `ssh -p 2222 -i ~/fbsd-vm/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost` (cloud-init, key only).
- `kldload /root/darwinator/darwinator.ko` is needed after a reboot; sysctls: `kern.darwinator.dyld=1 kern.darwinator.two_volumes=2 kern.darwinator.fast_sleep_ms=5` (the stack scripts set them).
- Window server: `WindowServer -t -s /tmp/WindowServer.sock` (headless, 1280x800). Test tools need `WS_SOCKET=/tmp/WindowServer.sock`: `wsshot out.ppm`, `wswins`, `wsclick x y`, `wskey code...` (`+cmd` modifiers), `wsmove`, `wsdrag`; convert with `ppm2png.py` (research/tools).
- Stack (real Dock/Finder): `d/session/pearos-desktop.sh`, `/root/run26.sh` (= stack26.sh). **Restart WindowServer whenever you restart the Dock**, else old tiles stay. The ssh session dies while the stack scripts run (they `pkill`): start with `nohup`, reconnect after ~10 s.
- Our apps (`open`): `open -a TextEdit file`, `open Stickies.app` (first start after a deploy sometimes shows no window: start again).
- Services for the GNUstep path: `/root/startbar.sh` (gdomap, gdnc, TopBar, Open and Save Panel Service).
- Never touch `/dev/sda` on the laptop (a USB stick may be there).

## Mac VM (macOS 26.7.2, reference + build host for Mach-O)
- OSX-KVM in `~/osx-vm/OSX-KVM` (`boot-macOS-headless.sh` style, ssh forward 2229), `ssh -p 2229 -i ~/fbsd-vm/id_ed25519 -o IdentitiesOnly=yes alex@localhost`. Display 1280x800.
- reims GPU VM (`reims-ctl start|stop mac`, ssh 2229 as above): SIP OFF since 2026-11-28 (owner allowed; `csr-active-config = FF0F0000` and boot-args `keepsyms=1 tlbto_us=0 vti=9 amfi_get_out_of_my_way=1` in `~/.local/share/reims-ctl/vms/mac/opencore.qcow2`, original in `opencore.qcow2.before-sip-off`).
- **sudo works with the password `pear` here too** (verified 2026-11-16: `echo pear | sudo -S -p "" CMD` as `alex`; SIP is disabled, authenticated root enabled, boot-args `keepsyms=1`). dtrace, fs_usage, nvram are therefore available.
- Used for: building Mach-O (`open/build-appkit.sh` via `open/deploy.sh`), `otool`, `lipo`, reading Apple files (via `macdeps`), measuring the real Dock/Finder.
- **Often slow or unresponsive**: use short timeouts, background the command, do not block the session. `screencapture` over ssh WORKS since 2026-11-16: a row was added to the system TCC.db (`kTCCServiceScreenCapture` for `/usr/libexec/sshd-keygen-wrapper`, auth_value 2; backup of the database at `/Users/alex/TCC.db.backup-before-screencapture`; to undo: `sudo cp` it back and `sudo killall tccd`). Use `ssh ... screencapture -x /tmp/s.png` then `scp` it and look at it (Read tool on the png).

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
- **dtrace gotcha**: `dtrace -o FILE` APPENDS and /tmp files made by root cannot be removed by `alex`; a failed script leaves the old file. Use a fresh file per run, `sudo rm` it, check the line count (research/dock-trace scripts do). `fs_usage` does not start on the Mac VM.
- **Accessibility over ssh works** on the Mac VM (TCC row kTCCServiceAccessibility for sshd-keygen-wrapper, backup `/Users/alex/TCC.db.backup-before-accessibility`): AXUIElement of the Dock gives every tile's title, role and frame (`~/bisect/ax <pid>` pattern in apps/dock-cocoa/README).
- To compare our Dock with the real one: `sh research/dock-trace/shot-ours.sh out.png` (stops the real Dock, runs ~/dock-cocoa, screenshot, restores the real Dock with bootstrap + kickstart) and `python3 research/dock-trace/pixdiff.py real.png out.png`.
- **Which Dock runs on the Mac VM**: `sh research/dock-trace/dock-switch.sh ours|real` (ours = launchd job `com.pearos.dock`, KeepAlive, real Dock booted out; real = Apple's job back). Since 2026-11-16 ~07:50 OURS is the one running (the user wanted to look at it). The screenshot scripts keep ours running (they restart it with the new build); to give the user the real Dock back: `dock-switch.sh real`.
- **TCC and our Dock**: the Dock bundle has CFBundleIdentifier com.apple.dock; TCC stores a code requirement (cdhash) for it at first use, so every new build is refused until it is cleared: `research/dock-trace/deploy-ours.sh` does that (rows Accessibility, ListenEvent, PostEvent for com.apple.dock, csreq NULL, then `killall tccd`) and re-signs ad hoc. Without it the CGEventTap fails with `post access 0`.
- **Mac VM boots from a COPY of the OpenCore image with AMFI relaxed (2026-11-16, user's permission)**: `~/osx-vm/OSX-KVM/OpenCore-Boot-amfi.sh` uses `OpenCore/OpenCore-amfi.qcow2` (boot-args `keepsyms=1 amfi_get_out_of_my_way=1`, csr-active-config FF0F0000, picker timeout 5 s, no install disk so it boots Untitled by itself); QEMU runs in `screen -S macvm` (window on the user's desktop; the monitor is on that screen's stdio). Restart it: `echo pear | sudo ssh ... shutdown -h now`, wait for qemu to exit, `screen -dmS macvm bash -c 'cd ~/osx-vm/OSX-KVM && ./OpenCore-Boot-amfi.sh'`. NVRAM boot-args set from macOS are LOST at reboot (OpenCore deletes and rewrites them): change the config in the qcow2 (`qemu-nbd -c /dev/nbd0`, mount nbd0p1, EFI/OC/config.plist, sudo pear on the laptop). The original image is untouched (`OpenCore-Boot.sh`).
- Our Dock is signed ad hoc WITH the real Dock's entitlements by deploy-ours.sh and runs under AMFI relaxed; the yellow (minimize) button still does nothing (see docs/development/DOCK-SERVER.md).
- Do not click blindly on the Mac VM: a wrong click launched Weather and a location dialog (harmless, VM is a lab VM, user does not care).
- **OpenCore picker**: the copy `OpenCore-amfi.qcow2` has `ScanPolicy = 0x10F0103` (APFS on SATA/SAS/SCSI/NVMe/PCI only; with 0 the picker also listed the EFI partition of the OpenCore disk and the default boot chose it; a wrong value 0x10A0103 hid the SATA disk). The Mac VM now boots Untitled by itself (verified: gui session 26 s after the start). The Dock job plist is in /tmp: after every Mac reboot run `sh research/dock-trace/dock-switch.sh ours`.
