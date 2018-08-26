#!/bin/bash

here=$(dirname "$0")
pushd $here

[ $(docker image ls firefly -q) ] ||
    docker build -t firefly .
[ $(docker container ls -aqf name=firefly) ] || 
    docker run --name firefly -e POSTGRES_PASSWORD=allowme -d firefly

docker container start firefly > /dev/null
sleep 2 # TODO: How to know when PSQL is available?
docker exec -it firefly psql -U postgres -c "select * from crew;"

popd
