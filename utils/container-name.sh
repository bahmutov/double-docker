#
# running the built image
#
if [ "$NODE_VERSION" == "" ]; then
  CONTAINER_NAME=dd-$NAME
else
  CONTAINER_NAME=dd-$NAME-$NODE_VERSION
fi
