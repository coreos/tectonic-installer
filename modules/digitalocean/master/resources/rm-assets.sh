#!/bin/bash
set -e
set -o pipefail

# shellcheck disable=SC2086,SC2154,SC2016
# Instead of deleting object, just overwrite it for simplicity's sake
touch /tmp/assets.zip
/opt/do-pusher.sh /tmp/assets.zip ${spaces_bucket}/assets.zip
rm /var/tmp/tectonic.zip
