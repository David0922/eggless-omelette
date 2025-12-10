#### manually create volume for rootless gitea

```bash
mkdir -p ./v/gitea/config ./v/gitea/data
sudo chown 1000:1000 ./v/gitea/config ./v/gitea/data
```

#### reverse ssh from localhost

use `autossh` instead of `ssh` to keep the ssh connection alive

```
autossh -M MONITORING_PORT -N -R REMOTE_PORT:localhost:LOCAL_PORT DOMAIN_NAME
```

e.g.

```
autossh -M 20000 -N -R 2201:localhost:2222 -R 8001:localhost:8080 gcp-tunnel
```
