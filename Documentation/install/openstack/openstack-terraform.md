# Install Tectonic on OpenStack with Terraform

Following this guide will deploy a Tectonic cluster within your OpenStack account.

Generally, the OpenStack platform templates adhere to the standards defined by the project [conventions][conventions] and [generic platform requirements][generic]. This document aims to document the implementation details specific to the OpenStack platform.

## Prerequsities

 - **CoreOS Container Linux** - The latest Container Linux Beta (1353.2.0 or later) [uploaded into Glance](https://coreos.com/os/docs/latest/booting-on-openstack.html) and its OpenStack image ID.
 - **Make** - This guide uses `make` to download a customized version of Terraform, which is pinned to a specific version and includes required plugins.
 - **Tectonic Account** - Register for a [Tectonic Account][register], which is free for up to 10 nodes. You will need to provide the cluster license and pull secret below.

## Getting Started
OpenStack is a highly customizable environment where different components can be enabled/disabled. This installation includes the following two flavors:

- `nova`: Only Nova computing nodes are being created for etcd, master and worker nodes, assuming the nodes get public IPs assigned.
- `neutron`: A private Neutron network is being created with master/worker nodes exposed via floating IPs connected to an etcd instance via an internal network.

Replace `<flavor>` with either option in the following commands. Now we're ready to specify our cluster configuration.

First, clone the Tectonic Installer repository in a convenient location:

```
$ git clone https://github.com/coreos/tectonic-installer.git
$ cd tectonic-installer
```

Download the pinned Terraform binary and modules required for Tectonic:

```
$ make terraform-download
```

After downloading, you will need to source this new binary in your `$PATH`. This is important, especially if you have another verison of Terraform installed. Run this command to add it to your path:

```
$ export PATH=/path/to/tectonic-installer/bin/terraform:$PATH
```

You can double check that you're using the binary that was just downloaded:

```
$ which terraform
/Users/coreos/tectonic-installer/bin/terraform/terraform
```

Next, get the modules that Terraform will use to create the cluster resources:

```
$ terraform get platforms/openstack/<flavor>
```

Configure your AWS credentials for setting up Route53 DNS record entries. See the [AWS docs][env] for details.

```
$ export AWS_ACCESS_KEY_ID=
$ export AWS_SECRET_ACCESS_KEY=
```

Set your desired region:

```
$ export AWS_REGION=
```

Configure your OpenStack credentials.

```
$ export OS_TENANT_NAME=
$ export OS_USERNAME=
$ export OS_PASSWORD=
$ export OS_AUTH_URL=
$ export OS_REGION_NAME=
```

## Customize the deployment

Customizations to the base installation live in `platforms/openstack/<flavor>/terraform.tfvars.example`. Export a variable that will be your cluster identifier:

```
$ export CLUSTER=my-cluster
```

Create a build directory to hold your customizations and copy the example file into it:

```
$ mkdir -p build/${CLUSTER}
$ cp platforms/openstack/<flavor>/terraform.tfvars.example build/${CLUSTER}/terraform.tfvars
```

Edit the parameters with your OpenStack details. View all of the [OpenStack Nova][openstack-nova-vars] and [OpenStack Neutron][openstack-neutron-vars] specific options and [the common Tectonic variables][vars].

## Deploy the cluster

Test out the plan before deploying everything:

```
$ terraform plan -var-file=build/${CLUSTER}/terraform.tfvars platforms/openstack/<flavor>
```

Next, deploy the cluster:

```
$ terraform apply -var-file=build/${CLUSTER}/terraform.tfvars platforms/openstack/<flavor>
```

This should run for a little bit, and when complete, your Tectonic cluster should be ready.

If you encounter any issues, check the known issues and workarounds below.

### Access the cluster

The Tectonic Console should be up and running after the containers have downloaded. You can access it at the DNS name configured in your variables file.

Inside of the `/generated` folder you should find any credentials, including the CA if generated, and a kubeconfig. You can use this to control the cluster with `kubectl`:

```
$ KUBECONFIG=generated/kubeconfig
$ kubectl cluster-info
```

### Delete the cluster

Deleting your cluster will remove only the infrastructure elements created by Terraform. If you selected an existing VPC and subnets, these items are not touched. To delete, run:

```
$ terraform destroy -var-file=build/${CLUSTER}/terraform.tfvars platforms/openstack/<flavor>
```

### Known issues and workarounds

If you experience pod-to-pod networking issues, try lowering the MTU setting of the CNI bridge.
Change the contents of `modules/bootkube/resources/manifests/kube-flannel.yaml` and configure the following settings:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-flannel-cfg
  namespace: kube-system
  labels:
    tier: node
    app: flannel
data:
  cni-conf.json: |
    {
      "name": "cbr0",
      "type": "flannel",
      "delegate": {
        "mtu": 1400,
        "isDefaultGateway": true
      }
    }
  net-conf.json: |
    {
      "Network": "${cluster_cidr}",
      "Backend": {
        "Type": "vxlan",
        "Port": 4789
      }
    }
```

Setting the IANA standard port `4789` can help debugging when using `tcpdump -vv -i eth0` on the worker/master nodes as encapsulated VXLAN packets will be shown.

See the [troubleshooting][troubleshooting] document for work arounds for bugs that are being tracked.

[conventions]: ../../conventions.md
[generic]: ../../generic-platform.md
[env]: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-environment
[register]: https://account.coreos.com/signup/summary/tectonic-2016-12
[account]: https://account.coreos.com
[vars]: ../../variables/config.md
[troubleshooting]: ../../troubleshooting.md
[openstack-nova-vars]: ../../variables/platform-openstack-nova.md
[openstack-neutron-vars]: ../../variables/platform-openstack-neutron.md
