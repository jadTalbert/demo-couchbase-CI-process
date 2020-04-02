#!/bin/bash

#this will forcably delete the specified local docker repo from your host. 

#docker repository from dockerhub.com(e.g. https://hub.docker.com/_/couchbase)
DOCKERREPOSITORY="couchbase"
#docker tag(e.g. couchbase:community-6.5.0)
DOCKERTAG="enterprise-6.0.2"

docker rmi -f $DOCKERREPOSITORY:$DOCKERTAG

exit 0
