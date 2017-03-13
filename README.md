# Tectonic Platform SDK

![Lifecycle Prototype](https://img.shields.io/badge/Lifecycle-Prototype-f4cccc.svg)

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

## OpenStack

### Nova network

Prerequsities:

1. The latest Container Linux Alpha (1339.0.0 or later) [uploaded into Glance](https://coreos.com/os/docs/latest/booting-on-openstack.html) and get the image ID
1. Since openstack nova doesn't provide any DNS registration service, AWS Route53 is being used.
Ensure you have a configured `aws` CLI installation.
1. Ensure you have OpenStack credentials set up, i.e. the environment variables `OS_TENANT_NAME`, `OS_USERNAME`, `OS_PASSWORD`, `OS_AUTH_URL`, `OS_REGION_NAME` are set.

```
$ ./convert.sh tfvars openstack assets/cloud-formation.json >config.tfvars
$ ./convert.sh assets openstack assets/
```

Next, set the image id from Glance in the config.tfvars file. Then invoke:

```
$ terraform apply -var-file="config.tfvars" openstack-novanet
...
null_resource.copy_assets: Still creating... (5m50s elapsed)
null_resource.copy_assets: Creation complete

Apply complete! Resources: 43 added, 0 changed, 0 destroyed.
```

The tectonic cluster will be reachable under `https://<name>.<base_domain>:32000`.

### Neutron network

The instructions for Neutron are the same as for Nova.

## AWS

*Common Prerequsities*

1. Configure AWS credentials via environment variables. 
[See docs](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-environment)
2. Configure a region by setting `AWS_REGION` environment variable
3. Run through the official Tectonic intaller steps without clicking `Submit` on the last step. 
Instead click on `Manual boot` below to download the assets zip file.
4. Create a folder with the cluster's name under `./build` (e.g. `./build/<cluster-name>`)
5. Copy the `assets-<cluster-name>.zip` to `./boot/<cluster-name>`

### Using Autoscaling groups

1. Ensure all *prerequsities* are met.
2. From the root of the repo, run `make PLATFORM=aws-asg CLUSTER=<cluster-name>`

To clean up run `make destroy PLATFORM=aws-asg CLUSTER=<cluster-name>`

### Without Autoscaling groups

1. Ensure all *prerequsities* are met.
2. From the root of the repo, run `make PLATFORM=aws-noasg CLUSTER=<cluster-name>`

To clean up run `make destroy PLATFORM=aws-noasg CLUSTER=<cluster-name>`

**TODO(alexsomesan)**

## VMware

Prerequsities:

1. Download the latest Container [Linux Stable OVA](https://stable.release.core-os.net/amd64-usr/current/) and [deploy a Virtual Machine with the OVA file](https://pubs.vmware.com/vsphere-60/index.jsp#com.vmware.vsphere.vm_admin.doc/GUID-AFEDC48B-C96F-4088-9C1F-4F0A30E965DE.html) and keep default settings.
1. Convert the Virtual Machine deployed into a [Virtual Machine template](https://pubs.vmware.com/vsphere-60/index.jsp#com.vmware.vsphere.vm_admin.doc/GUID-FE6DE4DF-FAD0-4BB0-A1FD-AFE9A40F4BFE_copy.html)
1. Since VMware doesn't provide any DNS registration service, AWS Route53 is being used.
Ensure you have a configured `aws` CLI installation.
1. Ensure you have vSphere credentials set up correctly (refer to vsphere.tf)

Execute convert.sh script with syntax below

```
$ ./convert.sh tfvars vmware assets/cloud-formation.json >config.tfvars
$ ./convert.sh assets vmware assets/
```
Next, set the CoreOS template name in the config.tfvars file. Then invoke:

```
$ terraform apply -var-file="config.tfvars" vmware
```

The tectonic cluster will be reachable under `https://<name>.<base_domain>:32000`.

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
