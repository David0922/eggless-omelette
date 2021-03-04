#!/bin/bash

REGISTRY='localhost:32000'

docker build -t curl-me .
docker tag curl-me $REGISTRY/curl-me
docker push $REGISTRY/curl-me
