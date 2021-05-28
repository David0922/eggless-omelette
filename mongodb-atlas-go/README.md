add to vscode `settings.json`

```json
"gopls": {
  "experimentalWorkspaceModule": true,
}
```

generate `go.sum`

```bash
go mod tidy
```

build binary

```
go build
```
