[Service]
Type=oneshot
ExecStart=/usr/bin/rkt run \
  --trust-keys-from-https \
  --volume assets,kind=host,source=${assets_path} \
  --mount volume=assets,target=/assets \
  ${bootkube_image} \
  --net=host \
  --exec=/bootkube -- start --asset-dir=/assets --etcd-server="${etcd_endpoint}"