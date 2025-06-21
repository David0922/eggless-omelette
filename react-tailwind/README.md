setup

```bash
pnpm install
```

run locally

```bash
pnpm dev
```

run production build

```bash
pnpm build
pnpm preview
```

containerize

```bash
podman build -t react-tailwind .
podman run --rm -it -p 8080:80 react-tailwind
```
