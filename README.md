# demo-couchbase-CI-process
This is a demo repo to show how to embed a CB instance in a CI/CD pipeline.

---  

**Note:** Docker must be installed on your host machine(s) for these scripts to work properly.

Also, make sure you ```chmod +x``` each file to ensure it is executable prior to executing the scripts.

---

#### initCouchbaseNode-docker.sh Usage:
  - This script is used to fully launch a Couchbase node running on the version of your choice(via docker tags). There is no manual set up required after the node is launched and the template can be customized for some basic settings. This will evolve over time and allow for MDS(Multi Dimensional Scaling and other settings via the REST APIs).


#### tearDownDockerImage.sh Usage:
  - This script will allow you to tear down an existing docker container to ensure you are not consuming resources on your CI server unnecessarily. Note, this does actually delete the container, so if you need the container, do not use this file. Again, this is meant to help you tear down your CI/CD environment as needed. There is no harm in deleting this, as the ```initCouchbaseNode-docker.sh``` will reconstitute the container on its next run.
#### deleteLocalDockerRepo.sh Usage:
  - This will forcably delete your local repository---even if there is an existing container running, so use this with caution. This can be used when you want to modify the ```initCouchbaseNode-docker.sh``` memory settings to ensure your changes take-effect between CI/CD executions. If your memory and other settings generally remain the same, there is no reason to delete the local repository. In addition, if you want to clean up the repository over time due to upgrades and/or testing different versions of Couchbase, this can be a handy script to have.
#### Automated Bucket Creation
  - The ```initCouchbaseNode-docker.sh``` script will automatically create a bucket for you based on the name you provide in the ```bucketName``` variable---note, the value cannot be empty. You can modify the bucket memory allocation at this time, but no other customization can be done at the moment.
#### Importing Documents
  - After your node is configured via the ```initCouchbaseNode-docker.sh``` script and your bucket has been created, you can use both [cbexport](https://docs.couchbase.com/server/6.5/tools/cbexport-json.html) and [cbimport](https://docs.couchbase.com/server/6.5/tools/cbimport-json.html) to export/import documents into your node.
#### CI/CD Considerations
  - There are many ways to handle this; however, the suggestion is to use your CI server to take advantage of minimizing manual processes. Bake these scripts into your pipeline in a way that is easy to manage and also helps you reduce manual testing and significantly improve your delivery quality and time.

#### Variable Definitions
  ```javascript
      - ADMINUSERNAME -> Couchbase administrator usename
      - ADMINPWD      -> administrative password
      - CONTAINERNAME -> name of docker container
      - DOCKERREPOSITORY -> dockerhub.com repo you want to use
      - DOCKERTAG -> dockerhub.com repo tag you want to use
      - SLEEP -> time in seconds the script will sleep. Default is 15 seconds
      - HOST -> IPv4 Address of your Couchbase node. Default is 127.0.0.1
      - HOSTPORT -> Couchbase port. Default is 8091
      - PROTOCOL -> Default is HTTP
      - MEMQUOTA -> amount of RAM for the data service. Default is 300
      - INDEXMEMQUOTA -> Amount of RAM for the index service. Default is 600
      - BUCKETNAME -> The name of your bucket. Default is myBucket
      - BUCKETAUTH -> auth type. Default is sasl
  ```
