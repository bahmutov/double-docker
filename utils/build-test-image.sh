#
# building derived image with current source and "npm test" command
#
echo "FROM $IMAGE_WITH_DEPS_NAME">DockerTestFile

if [ -f DockerTestTemplate ]; then
  echo "Build test image using your template file DockerTestTemplate"
  cat DockerTestTemplate>>DockerTestFile
else
  cat $DIR/docker-files/DockerNpmTest>>DockerTestFile
fi

if [ "$NODE_VERSION" == "" ]; then
  IMAGE_NAME=dd-child-$NAME
else
  IMAGE_NAME=dd-child-$NAME:$NODE_VERSION
fi

docker build -t $IMAGE_NAME -f DockerTestFile .
rm DockerTestFile
echo "Built docker image $IMAGE_NAME with source code"
