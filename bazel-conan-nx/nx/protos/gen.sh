#!/bin/bash

rm -rf ./src

pnpm buf generate ../../protos

for pb in ./src/gen/*_pb.ts; do
  echo "export * from './gen/$(basename $pb .ts).js';" >> ./src/index.ts
done
