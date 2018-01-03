#!/bin/bash
# This is a utility to upload a file to DigitalOcean Spaces object storage.
set -x
set -o pipefail

if [ "$#" -ne "2" ]; then
    echo "Usage: $0 source destination"
    exit 1
fi

export ACCESS_KEY_ID=${do_access_key_id}
export SECRET_ACCESS_KEY=${do_secret_access_key}
export REGION=${do_region}

# shellcheck disable=SC2034,SC1083
filename=$(basename $${1})
# shellcheck disable=SC2034,SC1083
cp $${1} /tmp
# A tool for interacting with DO's object storage: https://github.com/aknuds1/do-spaces-tool
docker pull aknudsen/do-spaces-tool:0.2.0 > /dev/null
# shellcheck disable=SC2034,SC1083
docker run -t --net=host -e ACCESS_KEY_ID -e SECRET_ACCESS_KEY -e REGION -v /tmp:/spaces aknudsen/do-spaces-tool:0.2.0 upload /spaces/$${filename} $${2}
rm -f /tmp/$${filename}
