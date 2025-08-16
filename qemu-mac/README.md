```bash
brew install qemu

wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64.img
```

```bash
qemu-img create -f qcow2 -o backing_file=devbox.qcow2,backing_fmt=qcow2 devbox-01.qcow2 40G
```

```bash
ssh -i ./id_rsa -p 2201 pika@localhost
```
