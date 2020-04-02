#!/bin/bash

#container name
CONTAINERNAME="cb602"
#docker repository from dockerhub.com(e.g. https://hub.docker.com/_/couchbase)
DOCKERREPOSITORY="couchbase"
#docker tag(e.g. couchbase:community-6.5.0)
DOCKERTAG="enterprise-6.0.2"

#notify the console
echo "Stopping container if it is already running"
#stop the container
docker stop $CONTAINERNAME

#notify the console
echo "Removing container -> " $CONTAINERNAME
#remove the specified container
docker rm $CONTAINERNAME

exit 0
