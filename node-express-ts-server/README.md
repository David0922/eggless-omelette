### setup

```bash
cd PROJ_DIR

yarn init -y

yarn add express

yarn add --dev \
  @types/express \
  @types/node \
  nodemon \
  npm-check-updates \
  ts-node \
  typescript

npx tsc --init
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
