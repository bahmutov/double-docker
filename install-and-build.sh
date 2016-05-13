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

. $DIR/utils/compute-sha.sh
. $DIR/utils/build-base-image.sh
. $DIR/utils/build-build-image.sh

#
# running the built image
#
CONTAINER_NAME=dd-$NAME-$NODE_VERSION

. $DIR/utils/stop-container.sh

echo "Running the \`npm build\` command in the docker container"
echo "image $IMAGE_NAME in $CONTAINER_NAME"
docker run --name $CONTAINER_NAME $IMAGE_NAME
