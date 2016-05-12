#!/usr/bin/env bash

set -xe

NODE_VERSION=0.12

PACKAGE_MD5=$(md5-cli package.json)
echo "Package.json md5: $PACKAGE_MD5"

NAME=test-autochecker
docker build -t $NAME-npm-deps:$PACKAGE_MD5 -f DockerDeps .

docker build -t $NAME:$NODE_VERSION -f DockerNpmTest .

docker run --name $NAME-$NODE_VERSION $NAME:$NODE_VERSION
