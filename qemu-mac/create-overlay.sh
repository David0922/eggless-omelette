#!/bin/bash

set -e -x

source load-env-var.sh

source create-seed.sh

qemu-img create -f qcow2 -o backing_file=$BASE_DISK_IMG,backing_fmt=qcow2 $DISK_IMG 40G
