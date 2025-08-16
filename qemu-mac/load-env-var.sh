#!/bin/bash

set -e -x

export CLOUD_IMG=/work-dir/tmp/noble-server-cloudimg-arm64.img

export ID=00
export VM_ID=devbox-$ID

export DISK_IMG=$VM_ID.qcow2
export SEED_IMG=$VM_ID-seed.img

export CPU=4
export MEMORY=4096
export DISK_SIZE=20G

export DEFAULT_USER=pika
export DEFAULT_PW=1234

# only used in create-overlay.sh
export BASE_DISK_IMG=../devbox-00/devbox-00.qcow2
