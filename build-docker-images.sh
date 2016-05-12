#!/usr/bin/env bash

set -e

NODE_VERSION=0.12

SHASUM=$(shasum package.json)
PACKAGE_SHA=($SHASUM)
echo "Package.json SHA: $PACKAGE_SHA"

NAME=test-autochecker
IMAGE_WITH_DEPS_NAME=$NAME-npm-deps:$PACKAGE_SHA

EXISTING_IMAGE=$(docker images -q $IMAGE_WITH_DEPS_NAME)
if [ "$EXISTING_IMAGE" == "" ]; then
  echo "Base NPM dependencies layer not found, building..."
  echo "FROM mhart/alpine-node:$NODE_VERSION">DockerDepsTemp
  cat DockerDeps>>DockerDepsTemp
  docker build -t $IMAGE_WITH_DEPS_NAME -f DockerDepsTemp .
  echo "Built NPM dependencies layer"
else
  echo "Base NPM dependencies already in existing docker image"
fi

echo "FROM $IMAGE_WITH_DEPS_NAME">DockerTestFile
cat DockerNpmTest>>DockerTestFile

docker build -t $NAME:$NODE_VERSION -f DockerTestFile .
echo "Built docker image with source code"

CONTAINER_NAME=$NAME-$NODE_VERSION
echo "Stopping and removing any existing containers"
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
echo "Running final docker image $CONTAINER_NAME"
docker run --name $CONTAINER_NAME $NAME:$NODE_VERSION
