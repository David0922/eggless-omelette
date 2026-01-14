#!/bin/bash

set -e -x

source load-env-var.sh

source create-seed.sh

if [ ! -f "$BASE_DISK_IMG" ]; then
  echo "$BASE_DISK_IMG doesn't exist"
  exit 1
fi

if [ -z "$DISK_IMG" ]; then
  echo 'DISK_IMG is empty or not set'
  exit 1
fi

qemu-img create -f qcow2 -o backing_file=$BASE_DISK_IMG,backing_fmt=qcow2 $DISK_IMG 40G
