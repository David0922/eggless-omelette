### build image

```
docker build --no-cache -t tunnel .
```

### run container

```
sudo docker run --rm -it --network host tunnel
```

### reverse ssh from localhost

```
autossh -M 20000 -N -R 8001:localhost:80 -R 44301:localhost:443 gcp-tunnel
```
