#!/bin/bash

set -e -x

rm -rf ./result ./root
mkdir -p ./root/etc

echo "$(id -gn):x:$(id -g):" >> ./root/etc/group
echo "$(id -un):x:$(id -u):$(id -g)::/:/bin/sh" >> ./root/etc/passwd

echo 'nameserver 8.8.8.8' >> ./root/etc/resolv.conf
echo 'nameserver 1.1.1.1' >> ./root/etc/resolv.conf

nix --extra-experimental-features nix-command build --file ./chroot.nix
nix --extra-experimental-features nix-command copy --no-check-sigs --to ./root --file ./chroot.nix
cp -a ./result/. ./root

sudo chown -R $(id -u):$(id -g) ./root
find ./root -type d -exec chmod 755 {} +

# sudo chroot --userspec=$(id -u):$(id -g) ./root /bin/bash
