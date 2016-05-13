#!/usr/bin/env bash

set -e

CONTAINER_IDS=$(docker ps -a --filter "name=dd-" -q)
if [ "$CONTAINER_IDS" == "" ]; then
  echo "No containers to remove"
else
  echo "Removing my docker containers"
  docker rm $CONTAINER_IDS
fi

DANGLING_IMAGES=$(docker images --filter "dangling=true" -q --no-trunc)
if [ "$DANGLING_IMAGES" == "" ]; then
  echo "No dangling images"
else
  docker rmi $DANGLING_IMAGES
fi

CHILD_IMAGES=$(docker images -q dd-child-*)
if [ "$CHILD_IMAGES" == "" ]; then
  echo "No child images to remove"
else
  echo "Removing my child images"
  docker rmi $CHILD_IMAGES
fi

BASE_IMAGES=$(docker images -q dd-npm-deps-*)

if [ "$BASE_IMAGES" == "" ]; then
  echo "No base images to remove"
else
  echo "Removing base images with npm deps"
  docker rmi $BASE_IMAGES
fi

