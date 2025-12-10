#### reverse ssh from localhost

use `autossh` instead of `ssh` to keep the ssh connection alive

```
autossh -M MONITORING_PORT -N -R REMOTE_PORT:localhost:LOCAL_PORT DOMAIN_NAME
```

e.g.

```
autossh -M 20000 -N -R 4202:localhost:2222 -R 8082:localhost:8080 gcp-tunnel
```
