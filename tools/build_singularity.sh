#!/bin/bash

set -eu

ver=$1

dockerimg=pndni/development-image:$ver

SINGULARITY_TMPDIR=$(mktemp -d -p .)
export SINGULARITY_TMPDIR

singularity build development-image-$ver.sif docker://$dockerimg
rm -rf $SINGULARITY_TMPDIR
