#
# building the base image with NPM dependencies if does not exist
#
if [ "$NODE_VERSION" == "" ]; then
  IMAGE_WITH_DEPS_NAME=dd-npm-deps-$NAME:$PACKAGE_SHA
else
  IMAGE_WITH_DEPS_NAME=dd-npm-deps-$NAME-$NODE_VERSION:$PACKAGE_SHA
fi

EXISTING_IMAGE=$(docker images -q $IMAGE_WITH_DEPS_NAME)
if [ "$EXISTING_IMAGE" == "" ]; then
  echo "Base NPM dependencies image $IMAGE_WITH_DEPS_NAME not found, building..."

  if [ -f DockerNpmDepsTemplate ]; then
    echo "Build using your template file DockerNpmDepsTemplate"
    docker build -t $IMAGE_WITH_DEPS_NAME -f DockerNpmDepsTemplate .
  else
    echo "FROM mhart/alpine-node:$NODE_VERSION">DockerDepsTemp
    if [ -f .npmrc ]; then
      cat $DIR/docker-files/DockerDepsWithNpmrc>>DockerDepsTemp
    else
      cat $DIR/docker-files/DockerDeps>>DockerDepsTemp
    fi
    docker build -t $IMAGE_WITH_DEPS_NAME -f DockerDepsTemp .
    rm DockerDepsTemp
  fi
  echo "Built NPM dependencies image $IMAGE_WITH_DEPS_NAME"
else
  echo "Base NPM dependencies in existing image $IMAGE_WITH_DEPS_NAME"
fi

