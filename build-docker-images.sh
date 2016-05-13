#!/usr/bin/env bash

set -e

NAME=${PWD##*/}
NODE_VERSION=$1
if [ "$NODE_VERSION" == "" ]; then
  NODE_VERSION=6
  echo "Using default Node version $NODE_VERSION"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# consider shrinkwrap if it exists
if [ -f npm-shrinkwrap.json ]; then
  SHASUM=$(shasum npm-shrinkwrap.json)
else
  SHASUM=$(shasum package.json)
fi
PACKAGE_SHA=($SHASUM)
echo "$NAME package dependencies file SHA: $PACKAGE_SHA"

IMAGE_WITH_DEPS_NAME=dd-npm-deps-$NAME-$NODE_VERSION:$PACKAGE_SHA

EXISTING_IMAGE=$(docker images -q $IMAGE_WITH_DEPS_NAME)
if [ "$EXISTING_IMAGE" == "" ]; then
  echo "Base NPM dependencies image $IMAGE_WITH_DEPS_NAME not found, building..."
  echo "FROM mhart/alpine-node:$NODE_VERSION">DockerDepsTemp
  if [ -f .npmrc ]; then
    cat $DIR/DockerDepsWithNpmrc>>DockerDepsTemp
  else
    cat $DIR/DockerDeps>>DockerDepsTemp
  fi
  docker build -t $IMAGE_WITH_DEPS_NAME -f DockerDepsTemp .
  rm DockerDepsTemp
  echo "Built NPM dependencies image $IMAGE_WITH_DEPS_NAME"
else
  echo "Base NPM dependencies in existing image $IMAGE_WITH_DEPS_NAME"
fi

echo "FROM $IMAGE_WITH_DEPS_NAME">DockerTestFile
cat $DIR/DockerNpmTest>>DockerTestFile

IMAGE_NAME=dd-child-$NAME:$NODE_VERSION
docker build -t $IMAGE_NAME -f DockerTestFile .
rm DockerTestFile
echo "Built docker image $IMAGE_NAME with source code"

CONTAINER_NAME=dd-$NAME-$NODE_VERSION
echo "Stopping and removing any existing containers for $CONTAINER_NAME"

RUNNING_CONTAINER_IDS=$(docker ps --filter "name=$CONTAINER_NAME" -q)
if [ "$RUNNING_CONTAINER_IDS" == "" ]; then
  echo "No running containers to stop"
else
  echo "Stopping container $CONTAINER_NAME"
  docker stop $RUNNING_CONTAINER_IDS
fi

CONTAINER_IDS=$(docker ps -a --filter "name=$CONTAINER_NAME" -q)
if [ "$CONTAINER_IDS" == "" ]; then
  echo "No containers to stop"
else
  echo "Removing container $CONTAINER_NAME"
  docker rm $CONTAINER_IDS
fi

echo "Running the tests in the final docker"
echo "image $IMAGE_NAME in $CONTAINER_NAME"
docker run --name $CONTAINER_NAME $IMAGE_NAME
