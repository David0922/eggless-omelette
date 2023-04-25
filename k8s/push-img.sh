#!/bin/bash

set -e -x

# microk8s local registry
REGISTRY='localhost:32000'

TAG=$(basename "$PWD")

docker build -t $TAG .
docker tag $TAG $REGISTRY/$TAG
docker push $REGISTRY/$TAG
