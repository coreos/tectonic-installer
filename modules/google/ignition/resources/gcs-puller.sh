#!/bin/bash
set -x

if [ "$#" -ne "2" ]; then
    echo "Usage: $0 location destination"
    exit 1
fi

docker pull google/cloud-sdk > /dev/null
gsutil="docker run -t --net=host -v /tmp:/gs google/cloud-sdk gsutil"
assets=$(basename ${1})

${gsutil} cp gs://${1} /gs/${assets}
/usr/bin/sudo mv /tmp/${assets} ${2}
