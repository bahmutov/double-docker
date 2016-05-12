#!/usr/bin/env bash

set -xe

NODE_VERSION=0.12

PACKAGE_MD5=$(md5-cli package.json)
echo "Package.json md5: $PACKAGE_MD5"

NAME=test-autochecker
IMAGE_WITH_DEPS_NAME=$NAME-npm-deps:$PACKAGE_MD5

EXISTING_IMAGE=$(docker images -q $IMAGE_WITH_DEPS_NAME)
if [ "$EXISTING_IMAGE" == "" ]; then
  docker build -t $IMAGE_WITH_DEPS_NAME -f DockerDeps .
  echo "Built NPM dependencies layer"
fi

echo "FROM $IMAGE_WITH_DEPS_NAME">DockerTestFile
cat DockerNpmTest>>DockerTestFile

docker build -t $NAME:$NODE_VERSION -f DockerTestFile .
echo "Built docker image with source code"

echo "Running final docket image"
CONTAINER_NAME=$NAME-$NODE_VERSION
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
docker run --name $CONTAINER_NAME $NAME:$NODE_VERSION
