echo "Stopping and removing any existing containers for $CONTAINER_NAME"
RUNNING_CONTAINER_IDS=$(docker ps --filter "name=$CONTAINER_NAME" -q)
if [ "$RUNNING_CONTAINER_IDS" == "" ]; then
  echo "No running containers to stop"
else
  echo "Stopping container $CONTAINER_NAME"
  docker stop $RUNNING_CONTAINER_IDS
fi

CONTAINER_IDS=$(docker ps -a --filter "name=$CONTAINER_NAME" -q)
if [ "$CONTAINER_IDS" == "" ]; then
  echo "No containers to stop"
else
  echo "Removing container $CONTAINER_NAME"
  docker rm $CONTAINER_IDS
fi
