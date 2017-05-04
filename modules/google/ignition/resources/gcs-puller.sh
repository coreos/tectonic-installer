#!/bin/bash

if [ "$#" -ne "2" ]; then
    echo "Usage: $0 location destination"
    exit 1
fi

alias gsutil='(docker images google/cloud-sdk || docker pull google/cloud-sdk) > /dev/null;docker run -t -i --net=host -v /tmp:/gs google/cloud-sdk gsutil'

# CoreOS will automatically pull the 'gcloud-sdk' docker image. If the GCE
# VMs are set up to allow storage.objectReader scope or better, then gsutil
# will be able to copy assets from GCS.
gsutil cp gs://${1} /gs/${1}
/usr/bin/sudo mv /tmp/${1} $2
