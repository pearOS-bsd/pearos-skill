#!/bin/sh
# FreeBSD build VM, normal start: a window with the virtio GPU, the disk is overlay.qcow2 (it keeps its changes; the base is disk.qcow2), the console on /tmp/vmcons
cd ~/fbsd-vm
rm -f /tmp/vmcons
exec qemu-system-x86_64 -enable-kvm -cpu host -smp 6 -m 8G -drive file=overlay.qcow2,if=virtio -netdev user,id=n0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=n0 -device virtio-vga-gl,xres=1280,yres=800 -display gtk,gl=on -chardev socket,id=ser0,path=/tmp/vmcons,server=on,wait=off,logfile=/tmp/darwinator-vm-serial.log -serial chardev:ser0 -monitor unix:/tmp/vmmon,server,nowait
