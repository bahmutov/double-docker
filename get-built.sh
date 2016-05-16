#!/usr/bin/env bash

set -e

NAME=${PWD##*/}
FOLDER_NAME=$1

if [ "$NODE_VERSION" == "" ]; then
  FOLDER_NAME="dist"
  echo "Will grab folder dist/"
fi

NODE_VERSION=$2
if [ "$NODE_VERSION" == "" ]; then
  NODE_VERSION=6
  echo "Using default Node version $NODE_VERSION"
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

# . $DIR/utils/compute-sha.sh
# . $DIR/utils/build-base-image.sh
# . $DIR/utils/build-build-image.sh

#
# running the built image
#
CONTAINER_NAME=dd-$NAME-$NODE_VERSION

# . $DIR/utils/stop-container.sh

echo "Grabbing $FOLDER_NAME built in container $CONTAINER_NAME"
rm -rf $FOLDER_NAME || true
CONTAINER_PATH=/usr/src/app/$FOLDER_NAME
docker cp $CONTAINER_NAME:$CONTAINER_PATH $FOLDER_NAME
ls -R $FOLDER_NAME
