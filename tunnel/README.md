### create a cloud vm

```
PROJ=
VM_NAME=tunnel
ZONE=us-west1-a
MACHINE_TPYE=e2-micro
SIZE=10GB

gcloud compute instances create $VM_NAME \
  --boot-disk-size=$SIZE \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=$MACHINE_TPYE \
  --project=$PROJ \
  --tags=http-server,https-server \
  --zone=$ZONE
```

### replace `DOMAIN_NAME` with an actual domain name

```
find . -type f -not -path ./README.md -exec sed -i 's/DOMAIN_NAME/ACTUAL_DOMAIN_NAME/' {} +
```

### enter `login` and `password` in `ddclient.conf`

### build image

```
docker build --network host -t tunnel .
```

### run container

```
sudo docker run --rm -it --network host tunnel
```

### reverse ssh from localhost

```
ssh -N -R 8080:localhost:LOCAL_PORT DOMAIN_NAME
```
