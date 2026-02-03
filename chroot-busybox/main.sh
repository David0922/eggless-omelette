#!/bin/bash

set -e -x

sudo umount ./root/dev || true
sudo umount ./root/proc || true

sudo rm -rf ./root
mkdir -p ./root/{bin,dev,etc,proc,tmp}

sudo mount --bind /dev ./root/dev
sudo mount --types proc proc ./root/proc

echo "$(id -gn):x:$(id -g):" >> ./root/etc/group
echo "$(id -un):x:$(id -u):$(id -g)::/:/bin/sh" >> ./root/etc/passwd

echo 'nameserver 1.1.1.1' >> ./root/etc/resolv.conf
echo 'nameserver 8.8.8.8' >> ./root/etc/resolv.conf

podman build -f busybox.Dockerfile -t install-busybox
podman run -v $(realpath ./root):/build install-busybox

mkdir -p ./root/etc/ssl/certs
curl -fsSL https://curl.se/ca/cacert.pem -o ./root/etc/ssl/certs/ca-certificates.crt

: 'sudo chroot --userspec=$(id -u):$(id -g) ./root /bin/sh -l'
