#!/bin/bash
set -e

# shellcheck disable=SC2154
/usr/bin/docker run \
    --volume "$(pwd)":/assets \
    --volume /etc/kubernetes:/etc/kubernetes \
    "${kube_core_renderer_image}" \
    --config=/assets/kco-config.yaml \
    --output=/assets

mkdir -p /etc/kubernetes/manifests/
mv /opt/tectonic/manifests/tectonic-node-controller-pod.yaml /etc/kubernetes/manifests/
cp -r $(pwd)/bootstrap-configs /etc/kubernetes/bootstrap-configs

# shellcheck disable=SC2154
/usr/bin/docker run \
    --volume "$(pwd)":/assets \
    --volume /etc/kubernetes:/etc/kubernetes \
    --network=host \
    --entrypoint=/bootkube \
    "${bootkube_image}" \
    start --asset-dir=/assets
