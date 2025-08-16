#!/bin/bash

set -e -x

CLOUD_IMG=/work-dir/tmp/noble-server-cloudimg-arm64.img

VM_ID=devbox

DISK_SIZE=20G

DEFAULT_USER=pika
DEFAULT_PW=1234

if [ ! -f "$CLOUD_IMG" ]; then
  echo "$CLOUD_IMG doesn't exist"
  exit 1
fi

ssh-keygen -t rsa -b 4096 -C '' -f ./id_rsa -N ''

cat << EOF > user-data
#cloud-config
hostname: $VM_ID
users:
  - name: $DEFAULT_USER
    groups: sudo
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    passwd: $(openssl passwd -6 $DEFAULT_PW)
    chpasswd:
      expire: false
    lock_passwd: false
    ssh_authorized_keys:
      - $(cat id_rsa.pub)
ssh_pwauth: true
EOF

cat << EOF > meta-data
instance-id: $VM_ID
local-hostname: $VM_ID
EOF

mkisofs -output $VM_ID-seed.img -volid cidata -rational-rock -joliet user-data meta-data

qemu-img create -f qcow2 -o backing_file=$CLOUD_IMG,backing_fmt=qcow2 $VM_ID.qcow2 $DISK_SIZE
