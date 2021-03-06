#!/usr/bin/env bash

set -e

NAME=${PWD##*/}
NODE_VERSION=$1
if [ -f $NODE_VERSION ]; then
  NODE_VERSION=
fi
if [ "$NODE_VERSION" == "" ]; then
  NODE_VERSION=6
  echo "Using default Node version $NODE_VERSION"
fi
if [ -f DockerNpmDepsTemplate ]; then
  NODE_VERSION=
  echo "Found Docker npm deps template file, no external node version then"
fi

# the folder with this script (for calling our utility scripts)
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative
  # to the path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
# echo "Script folder $DIR"

. $DIR/utils/compute-sha.sh
. $DIR/utils/build-base-image.sh
. $DIR/utils/build-test-image.sh
. $DIR/utils/container-name.sh
. $DIR/utils/stop-container.sh

echo "Running the tests in the final docker"
echo "image $IMAGE_NAME in $CONTAINER_NAME"
docker run --name $CONTAINER_NAME $IMAGE_NAME
