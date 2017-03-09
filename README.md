# Tectonic Platform SDK

The Tectonic Platform SDK provides pre-built recipes to help users create the underlying compute infrastructure for a [Self-Hosted Kubernetes Cluster](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/self-hosted-kubernetes.md) ([vid](https://coreos.com/blog/self-hosted-kubernetes.html)) using [Hashicorp Terraform](https://terraform.io), [bootkube](https://github.com/kubernetes-incubator/bootkube), and supporting tooling.

The goal is to provide well-tested defaults that can be customized for various environments and plugged into other systems.

The unique power of Self-Hosted Kubernetes is that it cleanly separates out the infrastructure from Kubernetes enabling this separation of concerns:

![](http://i.imgur.com/Gd9W7RR.gif)

## Getting Started

At this time the Platform SDK relies on the Tectonic Installer to generate all of the Kubernetes assests, certificates, etc. If you don't have a Tectonic installer already [sign-up for one for the free tier](https://coreos.com/tectonic) first, then:

1. Use the Tectonic installer to configure an AWS cluster.
2. Go through the process to create an AWS cluster, do not apply the configuration, but download the assets manually. This is an advanced option on the last screen
3. Unzip the assets in this directory:

```
$ unzip ~/Downloads/<name>-assets.zip
```

## Azure

1. Setup your DNS zone in a resource group called `tectonic-dns-group` or specify a different resource group. We use a separate resource group assuming that you have a zone that you already want to use.
1. Create a folder with the cluster's name under `./build` (e.g. `./build/<cluster-name>`)
1. Copy the `assets-<cluster-name>.zip` to `./boot/<cluster-name>`

```
make PLATFORM=azure CLUSTER=eugene
```

*Common Prerequsities*

1. Configure AWS credentials via environment variables.
[See docs](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-environment)
1. Configure a region by setting `AWS_REGION` environment variable
1. Run through the official Tectonic intaller steps without clicking `Submit` on the last step. 
Instead click on `Manual boot` below to download the assets zip file.
1. Create a folder with the cluster's name under `./build` (e.g. `./build/<cluster-name>`)
1. Copy the `assets-<cluster-name>.zip` to `./boot/<cluster-name>`

### Using Autoscaling groups

1. Ensure all *prerequsities* are met.
1. From the root of the repo, run `make PLATFORM=aws-asg CLUSTER=<cluster-name>`

To clean up run `make destroy PLATFORM=aws-asg CLUSTER=<cluster-name>`


## OpenStack

Prerequsities:

1. The latest Container Linux Alpha (1339.0.0 or later) [uploaded into Glance](https://coreos.com/os/docs/latest/booting-on-openstack.html) and get the image ID
1. Since openstack nova doesn't provide any DNS registration service, AWS Route53 is being used.
Ensure you have a configured `aws` CLI installation.
1. Ensure you have OpenStack credentials set up, i.e. the environment variables `OS_TENANT_NAME`, `OS_USERNAME`, `OS_PASSWORD`, `OS_AUTH_URL`, `OS_REGION_NAME` are set.
1. Create a folder with the cluster's name under `./build` (e.g. `./build/<cluster-name>`)
1. Copy the `assets-<cluster-name>.zip` to `./boot/<cluster-name>`

### Nova network

1. Ensure all *prerequsities* are met.
1. From the root of the repo, run `make PLATFORM=openstack-novanet CLUSTER=<cluster-name>`

To clean up run `make destroy PLATFORM=openstack-novanet CLUSTER=<cluster-name>`

The tectonic cluster will be reachable under `https://<name>.<base_domain>:32000`.

### Neutron network

1. Ensure all *prerequsities* are met.
1. From the root of the repo, run `make PLATFORM=openstack-neutron CLUSTER=<cluster-name>`

To clean up run `make destroy PLATFORM=openstack-neutron CLUSTER=<cluster-name>`

The tectonic cluster will be reachable under `https://<name>.<base_domain>:32000`.

## AWS

*Common Prerequsities*

1. Configure AWS credentials via environment variables. 
[See docs](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-environment)
1. Configure a region by setting `AWS_REGION` environment variable
1. Run through the official Tectonic intaller steps without clicking `Submit` on the last step. 
Instead click on `Manual boot` below to download the assets zip file.
1. Create a folder with the cluster's name under `./build` (e.g. `./build/<cluster-name>`)
1. Copy the `assets-<cluster-name>.zip` to `./boot/<cluster-name>`

### Using Autoscaling groups

1. Ensure all *prerequsities* are met.
1. From the root of the repo, run `make PLATFORM=aws-asg CLUSTER=<cluster-name>`

To clean up run `make destroy PLATFORM=aws-asg CLUSTER=<cluster-name>`

### Without Autoscaling groups

1. Ensure all *prerequsities* are met.
1. From the root of the repo, run `make PLATFORM=aws-noasg CLUSTER=<cluster-name>`

To clean up run `make destroy PLATFORM=aws-noasg CLUSTER=<cluster-name>`

## Roadmap

This is an unprioritized list of future items the team would like to tackle:

- Run [Kubernetes e2e tests](https://github.com/coreos-inc/tectonic-platform-sdk/issues/6) over repo automatically
- Build a tool to walk the Terraform graph and warn if cluster won't comply with [Generic Platform](https://github.com/coreos-inc/tectonic-platform-sdk/blob/master/Documentation/generic-platform.md)
- Additional platforms like Azure, VMware, Google Cloud, etc
- Create a spec for generic and platform specific Terraform Variable files
- Document how to customize each of the platforms
- Create a tool to verify Terraform Variable files
- Deploy with other self-hosted tools like kubeadm
- Terraform plugin and integration with [matchbox](https://github.com/coreos/matchbox) for bare metal
