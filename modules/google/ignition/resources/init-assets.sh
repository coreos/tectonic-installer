#!/bin/bash
set -e

# Download the assets from GCS
/usr/bin/bash /opt/gcs-puller.sh ${assets_gcs_location} /opt/tectonic/tectonic.zip
unzip -o -d /opt/tectonic/ /opt/tectonic/tectonic.zip
rm /opt/tectonic/tectonic.zip

exit 0
