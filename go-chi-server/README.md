### build docker image

```
docker build -t go-chi-server .
```

### run docker container

```
docker run --rm -it -p 3000:3000 go-chi-server
```

### verify that it works

```
curl localhost:3000
```
