### setup

```bash
cd PROJ_DIR

npm init -y
npx tsc --init

npm install express

npm install -D \
  @types/express \
  @types/node \
  nodemon \
  ts-node \
  typescript
```

#### tsconfig.json

```json
{
  "compilerOptions": {
    // ...
    "target": "es6",
    "outDir": "./dist",
    "rootDir": "./src",
    "moduleResolution": "node"
    // ...
  }
}
```

#### package.json

```json
{
  // ...
  "scripts": {
    "build": "npx tsc",
    "dev": "nodemon ./src/main.ts",
    "start": "node dist/main.js"
  }
  // ...
}
```
