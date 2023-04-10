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

use `autossh` instead of `ssh` to keep the tunnel alive

```
autossh -M MONITORING_PORT -N -R REMOTE_PORT:localhost:LOCAL_PORT DOMAIN_NAME
```

e.g.

```
autossh -M 20000 -N -R 4202:localhost:2222 -R 8082:localhost:8080 gcp-tunnel
```
