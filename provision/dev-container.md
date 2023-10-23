```bash
docker build \
  --build-arg "USER=$USER" \
  --build-arg "USER_UID=$(id -u)" \
  --build-arg "USER_GID=$(id -g)" \
  --no-cache \
  -t dev-env \
  https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/Dockerfile.dev
```

```bash
docker run \
  --name dev \
  --rm \
  -d \
  -p 2222:22 \
  -u $(id -u):$(id -g) \
  -v /etc/group:/etc/group:ro \
  -v /etc/passwd:/etc/passwd:ro \
  -v /work-dir/projects:/work-dir/projects \
  dev-env
```

```bash
docker kill dev
```
