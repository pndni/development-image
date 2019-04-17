#!/bin/bash

ver=$(git describe --tags)
ver=${ver:0:10}
if ! git diff --quiet
then
    ver=${ver}-dirty
fi

dockerimg=localhost:5000/development-image:$ver
docker build -t $dockerimg .
docker push $dockerimg

export SINGULARITY_NOHTTPS=1
singularity build development-image-$ver.simg docker://$dockerimg
