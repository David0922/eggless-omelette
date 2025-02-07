## install dependencies

```bash
pnpm install
```

## list all generators in the @nx/react plugin

```bash
pnpm nx list @nx/react
```

## generating a react app

```bash
pnpm nx generate @nx/react:application
```

## view details about å project

```bash
pnpm nx show project @nx/react_01
```

## dev

```bash
pnpm nx dev @nx/react_01
```

## build

```bash
# build all
pnpm nx run-many --targets=build

# build a target (e.g. react_01)
pnpm nx build react_01
```

## clear nx cache & shutdown nx daemon

```bash
pnpm nx reset
```
