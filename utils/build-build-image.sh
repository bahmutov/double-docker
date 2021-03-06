#
# building derived image with current source and "npm run build" command
#
echo "FROM $IMAGE_WITH_DEPS_NAME">DockerTempFile
cat $DIR/docker-files/DockerNpmRunBuild>>DockerTempFile

if [ "$NODE_VERSION" == "" ]; then
  IMAGE_NAME=dd-child-$NAME
else
  IMAGE_NAME=dd-child-$NAME:$NODE_VERSION
fi

docker build -t $IMAGE_NAME -f DockerTempFile .
rm DockerTempFile
echo "Built docker image $IMAGE_NAME"
echo "with source code and npm run build command"
