#!/bin/bash

set -e -x

source load-env-var.sh

if [ -z "$VM_ID" ]; then
  echo 'VM_ID is empty or not set'
  exit 1
fi

if [ -z "$CPU" ]; then
  echo 'CPU is empty or not set'
  exit 1
fi

if [ -z "$MEMORY" ]; then
  echo 'MEMORY is empty or not set'
  exit 1
fi

if [ ! -f "$DISK_IMG" ]; then
  echo "$DISK_IMG doesn't exist"
  exit 1
fi

if [ ! -f "$SEED_IMG" ]; then
  echo "$SEED_IMG doesn't exist"
  exit 1
fi

os="$(uname -s)"
arch="$(uname -m)"

if [[ "$os" == 'Linux' && "$arch" == 'x86_64' ]]; then
  qemu-system-x86_64 \
    -name $VM_ID \
    -machine type=q35,accel=kvm \
    -cpu host \
    -smp $CPU \
    -m $MEMORY \
    -drive if=virtio,format=qcow2,file=$DISK_IMG \
    -drive if=virtio,format=raw,file=$SEED_IMG \
    -nic user,model=virtio-net-pci,ipv6=off,hostfwd=tcp::22$ID-:22,hostfwd=tcp::30$ID-:3000,hostfwd=tcp::80$ID-:8080 \
    -nographic
elif [[ "$os" == 'Darwin' && ( "$arch" == 'aarch64' || "$arch" == 'arm64' ) ]]; then
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
else
    echo "unsupported platform: $os $arch"
    exit 1
fi
