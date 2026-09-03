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
  if ! ip link show "$BRIDGE" &>/dev/null; then
    echo "bridge $BRIDGE doesn't exist, run ./create-bridge.sh first"
    exit 1
  fi

  sudo qemu-system-x86_64 \
    -name $VM_ID \
    -machine type=q35,accel=kvm \
    -cpu host \
    -smp $CPU \
    -m $MEMORY \
    -drive if=virtio,format=qcow2,file=$DISK_IMG \
    -drive if=virtio,format=raw,file=$SEED_IMG \
    -nic bridge,br=$BRIDGE,model=virtio-net-pci,mac=$MAC \
    -nographic
elif [[ "$os" == 'Darwin' && ( "$arch" == 'aarch64' || "$arch" == 'arm64' ) ]]; then
  sudo qemu-system-aarch64 \
    -name $VM_ID \
    -machine type=virt,accel=hvf \
    -cpu host \
    -smp $CPU \
    -m $MEMORY \
    -bios QEMU_EFI.fd \
    -drive if=virtio,format=qcow2,file=$DISK_IMG \
    -drive if=virtio,format=raw,file=$SEED_IMG \
    -nic vmnet-shared,model=virtio-net-pci,mac=$MAC,start-address=10.0.2.2,end-address=10.0.2.254,subnet-mask=255.255.255.0 \
    -nographic
else
    echo "unsupported platform: $os $arch"
    exit 1
fi
