#!/bin/bash

set -e -x

# export CLOUD_IMG=/work-dir/tmp/resolute-server-cloudimg-amd64.img
# export CLOUD_IMG=/work-dir/tmp/resolute-server-cloudimg-arm64.img
# export CLOUD_IMG=/work-dir/tmp/ubuntu-26.04-minimal-cloudimg-amd64.img
export CLOUD_IMG=/work-dir/tmp/ubuntu-26.04-minimal-cloudimg-arm64.img

export ID=1
export ID_2=$(printf '%02d' $ID)
export VM_ID="devbox-$ID_2" # also used as hostname
export MAC="52:54:00:00:00:$ID_2"
export VM_IP="10.0.2.$((ID + 100))" # static IP on the devbox-br-0 subnet, gateway is 10.0.2.1

export DISK_IMG=$VM_ID.qcow2
export SEED_IMG=$VM_ID-seed.img

export CPU=4
export MEMORY=4096
export DISK_SIZE=20G

export DEFAULT_USER=pika
export DEFAULT_PW=1234

# only used in create-overlay.sh
export BASE_DISK_IMG=../devbox-00/devbox-00.qcow2
