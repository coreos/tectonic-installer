#!/bin/bash
set -e

s3_clean() {
  # Delete Install assets from S3
  # shellcheck disable=SC2086,SC2154,SC2016
  /usr/bin/docker run \
    --volume /tmp:/tmp \
    --network=host \
    --env LOCATION="${assets_s3_location}" \
    --entrypoint=/bin/bash \
    ${awscli_image} \
    -c '
        REGION=$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone | sed '"'"'s/[a-zA-Z]$//'"'"')
        usr/bin/aws --region=$${REGION} s3 rm s3://$${LOCATION}
    '
}

until s3_clean; do
  echo "failed to clean up S3 assets. retrying in 5 seconds."
  sleep 5
done
