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
