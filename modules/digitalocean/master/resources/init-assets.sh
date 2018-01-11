#!/bin/bash
set -e
set -o pipefail

# Download the assets from Spaces
# shellcheck disable=SC2154
/opt/do-puller.sh ${spaces_bucket}/assets.zip /var/tmp/tectonic.zip
/opt/do-puller.sh ${spaces_bucket}/kubeconfig /etc/kubernetes/kubeconfig
unzip -o -d /var/tmp/tectonic/ /var/tmp/tectonic.zip
rm /var/tmp/tectonic.zip
# make files in /opt/tectonic available atomically
mv /var/tmp/tectonic /opt/tectonic

exit 0
