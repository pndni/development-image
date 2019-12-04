#!/bin/bash

set -e
set -u
set -o pipefail

ver=$1
labelversion=$2
tmpdir=$(mktemp -d)

git clone git@github.com:pndni/development-image.git $tmpdir
pushd $tmpdir

git checkout $ver

lv=""
if [ $labelversion == 1 ]
then
    lv="--build-arg ver=$ver"
fi

docker build \
       --build-arg revision=$ver \
       --build-arg builddate="$(date --rfc-3339=seconds)" \
       $lv \
       -t pndni/development-image:$ver .

popd
rm -rf $tmpdir

docker push pndni/development-image:$ver
