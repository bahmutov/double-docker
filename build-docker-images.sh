#!/usr/bin/env bash

set -e

NAME=${PWD##*/}
NODE_VERSION=$1
if [ "$NODE_VERSION" == "" ]; then
  NODE_VERSION=6
  echo "Using default Node version $NODE_VERSION"
fi

# the folder with this script (for calling our utility scripts)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# prefer using shrinkwrap if it exists
if [ -f npm-shrinkwrap.json ]; then
  SHASUM=$(shasum npm-shrinkwrap.json)
else
  SHASUM=$(shasum package.json)
fi
PACKAGE_SHA=($SHASUM)
echo "$NAME package dependencies file SHA: $PACKAGE_SHA"

IMAGE_WITH_DEPS_NAME=dd-npm-deps-$NAME-$NODE_VERSION:$PACKAGE_SHA

. $DIR/build-base-image.sh

#
# building derived image with current source and "npm test" command
#
echo "FROM $IMAGE_WITH_DEPS_NAME">DockerTestFile
cat $DIR/DockerNpmTest>>DockerTestFile

IMAGE_NAME=dd-child-$NAME:$NODE_VERSION
docker build -t $IMAGE_NAME -f DockerTestFile .
rm DockerTestFile
echo "Built docker image $IMAGE_NAME with source code"

#
# running the built image
#
CONTAINER_NAME=dd-$NAME-$NODE_VERSION

. $DIR/stop-container.sh

echo "Running the tests in the final docker"
echo "image $IMAGE_NAME in $CONTAINER_NAME"
docker run --name $CONTAINER_NAME $IMAGE_NAME
