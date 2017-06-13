# Tectonic Offline Baremetal Install

**NOTE: as of tectonic version 1.7.1, you will need to use a [special tectonic installer branch](https://github.com/colhom/tectonic-installer/tree/1.7.3-tectonic.3-offline) in order to use this functionality**

The offline instructions will allow installation of Tectonic in an offline network environment (no outgoing internet access). This guide is meant as a supplement to the [tectonic terraform baremetal docs](https://coreos.com/tectonic/docs/latest/install/bare-metal/metal-terraform.html).

* Follow that guide up to the `terraform plan` step, stopping prior.

* Then follow this guide. You'll find that most of this has to do with either matchbox or exister container registry infrastructure.

* Finally resume the terraform baremetal installation instructions by executing the `terraform plan` and `terraform apply`.

## Requirements

* Matchbox server already deployed and configured
* Existing container image registry (quay or equivalent) which your tectonic cluster can access

## Basic approach
* Make sure matchbox already has coreos images in it
* Using your tectonic pull secret, sync the public tectonic registry cache image with your existing container image registry
* On startup, nodes will pull the registry cache and host it locally
* Kubernetes nodes and tectonic system services will use this local registry cache

## Installation Steps

### Ensure matchbox server has CoreOS image

**This is only necessary in environments where the server hosting matchbox does not have outgoing internet access. This does greatly reduce install time, so it is highly recommended.**

Examine your `terraform.tfvars` file and note values for `tectonic_metal_cl_version` and `tectonic_cl_channel`. Ensure that `/var/lib/matchbox` is pre-populated with the correct images via instructions [here](https://coreos.com/matchbox/docs/latest/deployment.html#download-coreos-optional)

### Provide organizational CA certificate bundle to terraform installer

Paste the contents of your organizational CA certificate into `tectonic_metal_customcacertificate` in your `terraform.tfvars` file. When the Tectonic Kubernetes nodes come up, this certificate will be added to the system CA bundle.

### Sync tectonic registry cache to your local image repository

#### Pull the tectonic registry cache image (requires internet access)

You will need to make sure your docker config contains your tectonic pull secret to access this image.

```sh
PULL_SECRET_PATH=/path/to/tectonic-pull-secret.json
mkdir ./tmp-config
cp ${PULL_SECRET_PATH} ./tmp-config/config.json
docker --config=./tmp-config pull quay.io/coreos/tectonic-registry-cache:1.7.3-tectonic.3
rm -r ./tmp-config
```

#### Push the tectonic registry cache to your local registry

The host is assumed to have `push` access to an existing repository already present on your existing container registry. As of `1.7.1`, this registry must not require docker credentials to pull.

```sh
# This registry repository must exist ahead of time
REGISTRY_REPO=example-registry.lab.local/my-team/tectonic-registry-cache
REGISTRY_IMAGE="${REGISTRY_REPO}:1.7.3-tectonic.3"

docker tag quay.io/coreos/tectonic-registry-cache:1.7.3-tectonic.3 ${REGISTRY_IMAGE}

docker push ${REGISTRY_IMAGE}
```

Next, set the applicable field in `terraform.tfvars` to tell the installer where the registry cache image was pushed to.

```
tectonic_registry_cache_image = "example-registry.lab.local/my-team/tectonic-registry-cache:1.7.3-tectonic.3"
```

### Override container image settings

Now you will modify `terraform.tfvars` and override the container image settings. This will tell tectonic installer and components how to talk to the tectonic registry cache running on each node.

The `tectonic-image-config` container tool can autogenerate the config snippet you'll need.

```sh
docker run -i --rm \
    quay.io/colin_hom/tectonic-image-config:v1.7.3-tectonic.3 \
    offline-image-config --tectonic-registry-host=localhost:5000 < /path/to/tectonic/config.tf

```

### Parametrize rkt image pulls

Add the following to the `terraform.tfvars` file. This tells rkt how to talk to the local registry cache on each node.

```
tectonic_rkt_insecure_options="image,http"
tectonic_rkt_image_protocol="docker://"
```

If your existing container repository is NOT quay, please also include. Some installations of quay may still require these fields as well, depending on how image signing and rkt fetch functionality is supported:

```
tectonic_registry_cache_rkt_protocol="docker://"
tectonic_registry_cache_rkt_insecure_options="image"
```

If your existing container repository DOES NOT have TLS enabled, you should set `tectonic_registry_cache_rkt_insecure_options="http,image"`.
