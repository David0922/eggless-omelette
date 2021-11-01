### setup golang proj

add to vscode `settings.json`

```json
"gopls": {
  "experimentalWorkspaceModule": true,
}
```

to create a new golang module outside of `$GOPATH`

```bash
go mod init <module-name>
```

generate / sync `go.sum`

```bash
go mod tidy
```

build binary

```bash
go build
```

### MongoDB (docker)

`MONGODB_URI='mongodb://username:password@addr'`

#### start MongoDB

```bash
docker run --rm -it \
  -e MONGO_INITDB_ROOT_USERNAME=username \
  -e MONGO_INITDB_ROOT_PASSWORD=password \
  -p 27017-27019:27017-27019 \
  -v /host/datadir:/data/db \
  --name mongodb mongo
```

#### mongo cli

```bash
docker exec -it mongodb mongo -u username -p password
```

### simple web server

```bash
busybox httpd -f -h . -p 0.0.0.0:8080 -v
```
