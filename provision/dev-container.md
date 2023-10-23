```bash
podman build \
  --no-cache \
  -t dev-env \
  https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/Dockerfile.dev
```

```bash
podman run \
  --name dev \
  --rm \
  -d \
  -p 2222:22 \
  -v /work-dir/projects:/work-dir/projects \
  dev-env
```

```bash
podman kill dev
```
