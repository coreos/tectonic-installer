#!/bin/bash

if [ "$#" -ne "2" ]; then
    echo "Usage: $0 location destination"
    exit 1
fi


#/usr/bin/sudo /usr/bin/rkt run \
#    --net=host --dns=host \
#    --trust-keys-from-https quay.io/coreos/awscli:025a357f05242fdad6a81e8a6b520098aa65a600 \
#    --volume=tmp,kind=host,source=/tmp --mount=volume=tmp,target=/tmp \
#    --set-env="LOCATION=$1" \
#    --exec=/bin/bash -- -c '
#        REGION=$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/[a-zA-Z]$//')
#        /usr/bin/aws --region=${REGION} gcs cp gs://${LOCATION} /tmp/${LOCATION//\//+}
#    '

# CoreOS will automatically pull the 'gcloud-sdk' docker image. If the GCE
# VMs are set up to allow storage.objectReader scope or better, then gsutil
# will be able to copy assets from GCS.
gsutil cp gs://${1} /tmp/${1}//\//+
/usr/bin/sudo mv /tmp/${1//\//+} $2
