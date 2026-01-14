#!/bin/bash

set -e -x

source load-env-var.sh

if [ ! -f "$CLOUD_IMG" ]; then
  echo "$CLOUD_IMG doesn't exist"
  exit 1
fi

if [ -z "$DISK_SIZE" ]; then
  echo 'DISK_SIZE is empty or not set'
  exit 1
fi

source create-seed.sh

qemu-img create -f qcow2 -o backing_file=$CLOUD_IMG,backing_fmt=qcow2 $VM_ID.qcow2 $DISK_SIZE
