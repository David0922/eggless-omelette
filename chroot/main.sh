#!/bin/bash

set -e -x

rm -rf ./root
mkdir -p ./root/bin ./root/etc

echo "$(id -gn):x:$(id -g):" >> ./root/etc/group
echo "$(id -un):x:$(id -u):$(id -g)::/:/bin/sh" >> ./root/etc/passwd

echo 'nameserver 8.8.8.8' >> ./root/etc/resolv.conf
echo 'nameserver 1.1.1.1' >> ./root/etc/resolv.conf

podman build -f busybox.Dockerfile -t install-busybox
podman run -v $(realpath ./root):/build install-busybox

# sudo chroot --userspec=$(id -u):$(id -g) ./root /bin/sh
