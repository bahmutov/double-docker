#
# building derived image with current source and "npm test" command
#
echo "FROM $IMAGE_WITH_DEPS_NAME">DockerTestFile
cat $DIR/docker-files/DockerNpmTest>>DockerTestFile

IMAGE_NAME=dd-child-$NAME:$NODE_VERSION
docker build -t $IMAGE_NAME -f DockerTestFile .
rm DockerTestFile
echo "Built docker image $IMAGE_NAME with source code"
