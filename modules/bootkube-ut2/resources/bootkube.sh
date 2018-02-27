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

# shellcheck disable=SC2154
/usr/bin/docker run \
    --detatch \
    --volume "$(pwd)":/assets \
    --publish 45900:45900
    "${tnc_bootstrap_image}" \
    --config=/assets/tnc-config.yaml \
    --port=45900 \
    --cert=/assets/tls/ca.crt \
    --key=/assets/tls/ca.key

# shellcheck disable=SC2154
/usr/bin/docker run \
    --volume "$(pwd)":/assets \
    --volume /etc/kubernetes:/etc/kubernetes \
    --network=host \
    --entrypoint=/bootkube \
    "${bootkube_image}" \
    start --asset-dir=/assets
