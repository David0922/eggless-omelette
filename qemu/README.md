## install qemu

```bash
# mac
brew install qemu
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64.img

# ubuntu
sudo apt install cloud-image-utils qemu-kvm
kvm-ok # make sure that `INFO: /dev/kvm exists` and `KVM acceleration can be used`
sudo usermod -a -G kvm $USER # log out and log back in for this to take effect
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

UEFI for arm: `/usr/share/qemu-efi-aarch64/QEMU_EFI.fd`

## create vm

```bash
# create vm from scratch
./create-vm.sh

# create vm from snapshot
./create-overlay.sh
```

## start vm

```bash
./start-vm.sh
```

## ssh into the vm

```bash
ssh -i ./id_rsa -p 2200 pika@localhost
```

## enter qemu monitor mode

linux: `ctrl-a c`

mac: `control-a c`

```
# map host's port 8080 to vm's port 80
(qemu) hostfwd_add tcp::8080-:80

# remove port mapping
(qemu) hostfwd_remove tcp::8080

# list port configuration
(qemu) info usernet

# sends ACPI powerdown signal (graceful shutdown)
(qemu) system_powerdown

# terminate qemu process immediately
(qemu) system_powerdown
```

## manually resize disk

```bash
# inspect a qemu disk image
qemu-img info file.qcow2

# set the disk size to 50 GB
qemu-img resize file.qcow2 50G

# increase the disk size by 50 GB
qemu-img resize file.qcow2 +50G
```
