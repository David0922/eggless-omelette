#!/bin/bash

set -e -x

source load-env-var.sh

qemu-system-aarch64 \
  -name $VM_ID \
  -machine type=virt,accel=hvf \
  -cpu host \
  -smp $CPU \
  -m $MEMORY \
  -bios QEMU_EFI.fd \
  -drive if=virtio,format=qcow2,file=$DISK_IMG \
  -drive if=virtio,format=raw,file=$SEED_IMG \
  -nic user,model=virtio-net-pci,ipv6=off,hostfwd=tcp::22$ID-:22,hostfwd=tcp::30$ID-:3000,hostfwd=tcp::80$ID-:8080 \
  -nographic
