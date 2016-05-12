#!/usr/bin/env bash

set -xe

NODE_VERSION=0.12

PACKAGE_MD5=$(md5-cli package.json)
echo "Package.json md5: $PACKAGE_MD5"

NAME=test-autochecker
docker build -t $NAME-npm-deps:$PACKAGE_MD5 -f DockerDeps .
echo "Built NPM dependencies layer"

echo "FROM $NAME-npm-deps:$PACKAGE_MD5">DockerTestFile
cat DockerNpmTest>>DockerTestFile

docker build -t $NAME:$NODE_VERSION -f DockerTestFile .
echo "Built docker image with source code"

echo "Running final docket image"
CONTAINER_NAME=$NAME-$NODE_VERSION
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
docker run --name $CONTAINER_NAME $NAME:$NODE_VERSION
