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

. $DIR/compute-sha.sh
. $DIR/build-base-image.sh
. $DIR/build-test-image.sh

#
# running the built image
#
CONTAINER_NAME=dd-$NAME-$NODE_VERSION

. $DIR/stop-container.sh

echo "Running the tests in the final docker"
echo "image $IMAGE_NAME in $CONTAINER_NAME"
docker run --name $CONTAINER_NAME $IMAGE_NAME
