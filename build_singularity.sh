#!/bin/bash

set -e

if ! ver=$(git describe --tags --exact-match 2> /dev/null)
then
    ver=$(git rev-parse HEAD)
    ver=${ver:0:10}
fi
if ! git diff --quiet
then
    ver=${ver}-dirty
fi

dockerimg=localhost:5000/development-image:$ver
docker build -t $dockerimg .
docker push $dockerimg

export SINGULARITY_NOHTTPS=1
singularity build development-image-$ver.simg docker://$dockerimg
