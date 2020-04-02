#!/bin/bash

# This script provides a convenient implementation for initializing a single Couchbase node using docker.
# This is not currently built to implement MDS(Multi Dimensional Scaling) nor does it support multiple buckets at the moment

#admin username
ADMINUSERNAME="Administrator"
#admin password
ADMINPWD="password"
#container name
CONTAINERNAME="cb602"
#docker repository from dockerhub.com(e.g. https://hub.docker.com/_/couchbase)
DOCKERREPOSITORY="couchbase"
#docker tag(e.g. couchbase:community-6.5.0)
DOCKERTAG="enterprise-6.0.2"
#time to sleep (in seconds) after the docker image is pulled from the repo. This allows enough time for the server to be configured via the REST APIs.
SLEEP=15
#host IP or FQDN
HOST="127.0.0.1"
#host port
HOSTPORT="8091"
#http protocol
PROTOCOL="http"
#memory quota
MEMQUOTA="300"
#index memory quotas
INDEXMEMQUOTA="600"
#name of your bucket
BUCKETNAME="myBucket"
#bucket auth type(e.g. none or sasl). Note, if you change the default from sasl to none you will have to to specify the proxy setting
BUCKETAUTH="sasl"

check_docker_install(){
  if [ -x "$(command -v docker)" ]; then
      echo "|--------------------------------------------------|"
      echo "|------------  Docker already installed     -------|"
      echo "|--------------------------------------------------|"
  else
      echo "|----------------------------------------------------------------------------------|"
      echo "|------------    Docker is not installed, so aborting the process.    -------------|"
      echo "|----------------------------------------------------------------------------------|"
      exit 1
  fi
}

#check to see if docker is installed before we continue
check_docker_install

#configure the couchbase server based on the settings in this file
initialize_server(){
  # Setup index and memory quota via the REST APIs on for the target couchbase node
  curl -v -X POST $PROTOCOL://$HOST:$HOSTPORT/pools/default -d memoryQuota=$MEMQUOTA -d indexMemoryQuota=$INDEXMEMQUOTA
  #notify the console that we are setting up the memory quotas
  echo "|-------------------------------------------------------------|"
  echo "|-------------    configuring the memory quota    ------------|"
  echo "|-------------------------------------------------------------|"

  # Setup services(e.g. N1QL, index,data etc.)
  curl -v $PROTOCOL://$HOST:$HOSTPORT/node/controller/setupServices -d services=kv%2Cn1ql%2Cindex
  #notify the console we are configuring the couchbase services
  echo "|-------------------------------------------------------------------|"
  echo "|-------------    configuring the couchbase services   -------------|"
  echo "|-------------------------------------------------------------------|"
  echo

  # Setup credentials
  curl -v $PROTOCOL://$HOST:$HOSTPORT/settings/web -d port=$HOSTPORT -d username=$ADMINUSERNAME -d password=$ADMINPWD
  #empty echo to simulate line feed in the console
  echo
  #notify the console we are setting up the credentials
  echo "|---------------------------------------------------------------------------------|"
  echo "|------------    setting the couchbase administrative credentials   --------------|"
  echo "|---------------------------------------------------------------------------------|"
  echo

  #create the specified bucket
  echo "|---------------------------------------------------------------|"
  echo "                Creating bucket -> $BUCKETNAME                   "
  echo "|---------------------------------------------------------------|"
  curl -X POST -u $ADMINUSERNAME:$ADMINPWD $PROTOCOL://$HOST:$HOSTPORT/pools/default/buckets/ -d name=$BUCKETNAME -d ramQuotaMB=$MEMQUOTA -d authType=$BUCKETAUTH

}

#if we do NOT find the docker repo locally, then download it and beging setting up the node
if [[ "$(docker images -q $DOCKERREPOSITORY:$DOCKERTAG 2> /dev/null)" == "" ]]; then
   #notify the console for information purposes
   echo "|---------------------------------------------------------------|"
   echo "  downloading docker image -> $DOCKERREPOSITORY:$DOCKERTAG   "
   echo "|---------------------------------------------------------------|"
   #pull the image from the docker repository
   docker run -d --name $CONTAINERNAME -p 8091-8094:8091-8094 -p 11210:11210 $DOCKERREPOSITORY:$DOCKERTAG
   #notify the console about the sleep time, so that the user knows we are still working
   echo "sleeping for $SLEEP seconds"
   #sleep for the specified number of seconds
   sleep $SLEEP
   #configure the couchbase server based on the settings in this file
   initialize_server
   #successfully exit the script
   exit 0
#else, the image exists locally, so just tear things down and built them up to ensure a clean environment
else
  echo "Docker repository exists locally ->" $DOCKERREPOSITORY:$DOCKERTAG
  echo "Stopping container if it is already running"
  #stop the container
  docker stop $CONTAINERNAME
  # the logic between the START and END comments is in place to allow you to modify the memory settings between tests. If you do not want/need this funcitonality, you
  # can remove the logic or comment it out to avoid waiting on the sleep time between executions.
  ###### START ######
  echo "Removing container -> " $CONTAINERNAME
  docker rm $CONTAINERNAME
  docker run -d --name $CONTAINERNAME -p 8091-8094:8091-8094 -p 11210:11210 $DOCKERREPOSITORY:$DOCKERTAG
  echo "sleeping $SLEEP seconds to wait for server to initialize->"
  sleep $SLEEP
  ###### END ######
  echo "|---------------------------------------------------------------|"
  echo "|-------------      Starting the container   -------------------|"
  echo "|---------------------------------------------------------------|"
  docker start $CONTAINERNAME
  #configure the couchbase server based on the settings in this file
  initialize_server
  #successfully exit the script
  exit 0
fi
