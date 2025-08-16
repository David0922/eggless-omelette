#!/bin/bash

set -e -x

source load-env-var.sh

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
