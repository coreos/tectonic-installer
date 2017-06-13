#!/bin/bash

/usr/bin/rkt run \
  --trust-keys-from-https \
  --volume assets,kind=host,source="$(pwd)" \
  --mount volume=assets,target=/assets \
  --insecure-options=${rkt_insecure_options} \
  ${rkt_image_protocol}${hyperkube_image} \
  --net=host \
  --dns=host \
  --exec=/bin/bash -- /assets/tectonic.sh /assets/auth/kubeconfig /assets ${experimental}
