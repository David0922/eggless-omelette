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

### modify config.yml

### generate ddclient.conf, nginx.conf, provision.sh from config.yml

```
python ./main.py
```

### build image

```
cd output
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
