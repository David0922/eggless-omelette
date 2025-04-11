## install dependencies

```bash
pnpm install
```

## add dependencies

```bash
# prod dependencies (e.g. connect rpc)
pnpm add --workspace-root  @connectrpc/connect @connectrpc/connect-web @bufbuild/protobuf

# dev dependencies (e.g. connect rpc)
pnpm add --workspace-root --save-dev @bufbuild/buf @bufbuild/protoc-gen-es
```

## list all generators in the @nx/react plugin

```bash
pnpm nx list @nx/js
pnpm nx list @nx/react
```

## generae a package (e.g. react app)

```bash
pnpm nx generate @nx/js:library my_lib
pnpm nx generate @nx/react:application react_01
```

add `my_lib` to `react_01/package.json`

```json
  "devDependencies": {
    "@dummy/my_lib": "workspace:*"
  }
```

## delete a package

```bash
pnpm nx generate remove @dummy/react_01
pnpm install

grep -inr react_01 .

# manually delete entries from:
#   ./pnpm-workspace.yaml
#   ./tsconfig.json
```

## view details about å project

```bash
pnpm nx show project @dummy/react_01
```

## dev

```bash
pnpm nx dev @dummy/react_01
```

## build

```bash
# build all
pnpm nx run-many --targets=gen --verbose
pnpm nx run-many --targets=build --verbose

# build a target (e.g. react_01)
pnpm nx build react_01
```

## run dev

```bash
pnpm nx dev react_01
```

## run prod

```bash
pnpm nx preview react_01
```

## clear nx cache & shutdown nx daemon

```bash
pnpm nx reset
```
