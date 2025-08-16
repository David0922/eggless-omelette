#!/bin/bash

set -e -x

VM_ID=devbox

CPU=4
MEMORY=4096

DISK_IMG=$VM_ID.qcow2
SEED_IMG=$VM_ID-seed.img

qemu-system-aarch64 \
  -name $VM_ID.qcow2 \
  -machine type=virt,accel=hvf \
  -cpu host \
  -smp $CPU \
  -m $MEMORY \
  -bios QEMU_EFI.fd \
  -drive if=virtio,format=qcow2,file=$DISK_IMG \
  -drive if=virtio,format=raw,file=$SEED_IMG \
  -nic user,model=virtio-net-pci,ipv6=off,hostfwd=tcp::2201-:22,hostfwd=tcp::8081-:8080 \
  -nographic
