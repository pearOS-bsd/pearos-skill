#!/bin/sh
# FreeBSD build / dev VM with a virtio GPU with 3D (virgl) rendered by the host's GPU, no window
cd ~/fbsd-vm
exec qemu-system-x86_64 -enable-kvm -cpu host -smp 8 -m 12G -drive file=disk.qcow2,if=virtio -netdev user,id=n0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=n0 -device virtio-vga-gl,xres=1920,yres=1080 -display egl-headless,rendernode=/dev/dri/renderD128 -serial file:serial.log
