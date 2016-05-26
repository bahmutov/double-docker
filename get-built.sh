#!/usr/bin/env bash

set -e

NAME=${PWD##*/}
FOLDER_NAME=$1
NODE_VERSION=$2

if [ "$FOLDER_NAME" == "" ]; then
  FOLDER_NAME="dist"
  echo "Will grab folder dist/"
fi

if [ -f DockerNpmDepsTemplate ]; then
  NODE_VERSION=
  echo "Found Docker npm deps template file, no external node version then"
fi

echo "Grabbing $FOLDER_NAME"

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

. $DIR/utils/container-name.sh

echo "Grabbing $FOLDER_NAME built in container $CONTAINER_NAME"
rm -rf $FOLDER_NAME || true
CONTAINER_PATH=/usr/src/app/$FOLDER_NAME
docker cp $CONTAINER_NAME:$CONTAINER_PATH $FOLDER_NAME
echo "Got the following files in $FOLDER_NAME"
ls -lR $FOLDER_NAME
