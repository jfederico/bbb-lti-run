#!/bin/bash

DockerComposeRoot=/home/jesus/Workspaces/bbb-lti-run

set -o allexport; source $DockerComposeRoot/.env; set +o allexport

DOCKER_REPO=${DOCKER_REPO:-bigbluebutton}
DOCKER_TAG=${DOCKER_TAG:-latest}

BROKER_STATUS="Status: Downloaded newer image for $DOCKER_REPO/bbb-lti-broker:$DOCKER_TAG"
broker_new_status=$(sudo docker pull $DOCKER_REPO/bbb-lti-broker:$DOCKER_TAG | grep Status:)
echo $broker_new_status

ROOMS_STATUS="Status: Downloaded newer image for $DOCKER_REPO/bbb-app-rooms:$DOCKER_TAG"
rooms_new_status=$(sudo docker pull $DOCKER_REPO/bbb-app-rooms:$DOCKER_TAG | grep Status:)
echo $rooms_new_status


if [ "$BROKER_STATUS" == "$broker_new_status" ] || [ "$ROOMS_STATUS" == "$rooms_new_status" ]
then
  cd $DockerComposeRoot
  sudo docker-compose down
  sudo docker rmi $(sudo docker images -f dangling=true -q)
  sudo docker-compose up -d
fi

exit 0
