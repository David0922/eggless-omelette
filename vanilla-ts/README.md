setup

```bash
yarn
yarn ncu -u
yarn install
```

run locally

```basj
yarn build
yarn start
```

containerize

```bash
docker build -t vanilla-ts .
docker run --rm -it -p 8080:80 vanilla-ts
```
