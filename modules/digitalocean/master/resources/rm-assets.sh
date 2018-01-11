#!/bin/bash
set -e
set -o pipefail

# Instead of deleting object, just overwrite it for simplicity's sake
touch /tmp/assets.zip
/opt/do-pusher.sh /tmp/assets.zip ${spaces_bucket}/assets.zip
rm /var/tmp/tectonic.zip
