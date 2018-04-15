#!/bin/bash
set +ex

# Update this version in cadence with the KUBE_CONFORMANCE_IMAGE in the Jenkinsfile
E2E_REF="v1.9.6_coreos.0"

# Replace '_' with '+'
E2E_REF_VER="${E2E_REF/_/+}"
docker build \
  --tag="quay.io/coreos/kube-conformance:${E2E_REF}" \
  --build-arg="E2E_REF=${E2E_REF_VER}" \
  .
