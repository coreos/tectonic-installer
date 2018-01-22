## Background

The  terraform installer provides a list of docker images required for a Tectonic install. These images are configurable via the `tectonic_containter_images` variable.

In situations where the cluster will not or cannot use public image registries, users can configure the installer to build a cluster using images from alternative registries.

**terraform.tfvars**:

```
tectonic_container_images = {
    etcd                            = "quay-lab.tectonic.dev/tectonic-mirror/etcd:v3.1.6"
    node_agent                      = "quay-lab.tectonic.dev/tectonic-mirror/node-agent:787844277099e8c10d617c3c807244fc9f873e46"
    prometheus_operator             = "quay-lab.tectonic.dev/tectonic-mirror/prometheus-operator:v0.9.1"
    node_exporter                   = "quay-lab.tectonic.dev/tectonic-mirror/node-exporter:v0.14.0"
...

```

The most common case where this pattern arises is when installing Tectonic in an environment with restricted or non-existent public internet access (egress).

In any case, the assumption is made that there is at least a single image registry accessible from where Tectonic is being installed. This can is generally a Quay Enterprise or other registry.

## Problem Statement

Configuring the image registry can be a bit of an arduous process. The following steps need to be done for each image in `tectonic_container_images`

```
# make sure quay-lab.tectonic.dev/tectonic-mirror/etcd repository exists already
# make sure Tectonic nodes can pull from quay-lab.tectonic.dev/tectonic-mirror/etcd

docker login quay-lab.tectonic.dev

docker pull quay.io/coreos/etcd:v3.1.6
docker tag quay.io/coreos/etcd:v3.1.6 quay-lab.tectonic.dev/tectonic-mirror/etcd:v3.1.6
docker push quay-lab.tectonic.dev/tectonic-mirror/etcd:v3.1.6

# modify terraform.tfvars to override `tectonic-container-images["etcd"]` image
```

As new versions of tectonic come out, it will be possible that image repositories will be added or removed from `tectonic_container_images` as well.

## Solution outline

It Would Be Nice &trade; if the installer offered to make this simpler for the user and relieve them from having to deal with image dependencies individually.

We could potentially do this via a separate `registry-configuration` terraform module.

Initially we would probably want to support Quay and Artifactory, as those seem to be the most prevelant in the field.

Configuring the installer to do all this for you could be as simple as:

**terraform.tfvars**:

```
tectonic_registry_host = "quay-lab.tectonic.dev"
tectonic_registry_org = "tectonic-mirror"

tectonic_registry_flavor = "quay"
tectonic_registry_api_credentials = "<registry-specific-api-credentials>"
```

In particular, it would very nice to unburden the user from having to manually override each `tectonic_container_image` and do it for them.

The user would simply have to ensure that the registry host is accessible and that the organization already exists before running the installer.

The installer would then know to:

 * docker pull all the default container images from public repositories (using tectonic-pull-secret)
 * override each image location to `${var.tectonic_registry_host}/${var.tectonic_registry_org}/${image_name}:${image_version}`
  * ensure each overriden image repository exists (requires integration w/ registry API. Both Quay and Artifactory have APIs)
 * configure access rules for override repository
 * docker push each image to it's repository

## Update support

When a new version of Tectonic is released, users can re-run the `registry-configuration` terraform module and sync the necessary containers to their Quay or Artifactory instance. This would involve pulling and pushing new image versions, creating new image repositories where necessary.


