# Install Tectonic on VMware with Terraform

Following this guide will deploy a Tectonic cluster within your VMware vSphere infrastructure .

Generally, the VMware platform templates adhere to the standards defined by the project [conventions][conventions] and [generic platform requirements][generic]. This document aims to document the implementation details specific to the VMware platform.

## Prerequsities

1. Download the latest Container Linux Stable OVA from; https://coreos.com/os/docs/latest/booting-on-vmware.html.
1. Import `coreos_production_vmware_ova.ova` into vCenter. For the most part all settings can be kept as is, however in "Customize template" you *must* change "DHCP Support for Interface 0" to **"no"**. See [1802](https://github.com/coreos/bugs/issues/1802)
1. Resize the Virtual Machine Disk size to 30 GB or larger
1. Convert the Container Linux image into a Virtual Machine template.
1. Pre-Allocated IP addresses for the cluster and pre-create DNS records
1. Register for Tectonic [Account][account]

## DNS and IP address allocation

Prior to the start of setup create required DNS records. Below is a sample table of 3 etcd nodes, 2 master nodes and 2 worker nodes. 

| Record | Type | Value |
|------|-------------|:-----:|
|mycluster.mycompany.com | A | 192.168.246.30 |
|mycluster.mycompany.com | A | 192.168.246.31 |
|mycluster-k8s.mycompany.com | A | 192.168.246.20 |
|mycluster-k8s.mycompany.com | A | 192.168.246.21 |
|mycluster-worker-0.mycompany.com | A | 192.168.246.30 |
|mycluster-worker-1.mycompany.com | A | 192.168.246.31 |
|mycluster-master-0.mycompany.com | A | 192.168.246.20 |
|mycluster-master-1.mycompany.com | A | 192.168.246.21 |
|mycluster-etcd-0.mycompany.com | A | 192.168.246.10 |
|mycluster-etcd-1.mycompany.com | A | 192.168.246.11 |
|mycluster-etcd-2.mycompany.com | A | 192.168.246.12 |

See [Tectonic on Baremetal DNS documentation][baremetaldns] for general DNS Requirements.

## Getting Started

Below steps need to be executed on machine that has network connectivity to VMware vCenter API and SSH access to Tectonic Master Server(s).

First, [download][downloadterraform] and install Terraform. 

After downloading, you will need to source this new binary in your `$PATH`. Run this command to add it to your path:

```
$ export PATH=$/path/to/terraform:$PATH
```

Now we're ready to specify our cluster configuration.

## Customize the deployment

Customizations to the base installation live in `examples/terraform.tfvars.<flavor>`. Export a variable that will be your cluster identifier:

```
$ export CLUSTER=my-cluster
```

Create a build directory to hold your customizations and copy the example file into it:

```
$ mkdir -p build/${CLUSTER}
$ cp examples/terraform.tfvars.vmware build/${CLUSTER}/terraform.tfvars
$ cd build/${CLUSTER}/
```

Edit the parameters with your VMware infrastructure details. View all of the [VMware][vmware] specific options and [the common Tectonic variables][vars].

## Deploy the cluster

Get the modules that Terraform will use to create the cluster resources:

```
$ terraform get ../../platforms/vmware
```

Test out the plan before deploying everything:

```
$ terraform plan ../../platforms/vmware
```

You will be prompted for vSphere credentials:

```
provider.vsphere.password
  The user password for vSphere API operations.

  Enter a value: 

provider.vsphere.user
  The user name for vSphere API operations.

  Enter a value: 
```

Next, deploy the cluster:

```
$ terraform apply ../../platforms/vmware
```

Wait for `terraform apply` until all tasks complete. Your Tectonic cluster should be ready. If you encounter any issues, check the known issues and workarounds below.

## Access the cluster

The Tectonic Console should be up and running after the containers have downloaded. You can access it at the DNS name configured as `tectonic_vmware_ingress_domain` in your `terraform.tfvars` variables file.

Inside of the `/generated` folder you should find all credentials, including the CA if generated, and a kubeconfig. You can use this to control the cluster with `kubectl`:

```
$ export KUBECONFIG=generated/auth/kubeconfig
$ kubectl cluster-info
```

## Working with the cluster

### Scaling Tectonic VMware clusters

This document describes how to add cluster nodes to Tectonic clusters on bare metal.

#### Scaling worker nodes

To scale worker nodes, adjust `tectonic_worker_count`, `tectonic_vmware_worker_hostnames` and `tectonic_vmware_worker_ip` variables in `terraform.tfvars` and run:

```
$ terraform plan \
  ../../platforms/vmware
$ terraform apply \
  ../../platforms/vmware
```
Shortly after running `terraform apply` you should see new worker machines on Tectonic console.

#### Scaling controller nodes

To scale worker nodes, adjust `tectonic_master_count`, `tectonic_vmware_master_hostnames` and `tectonic_vmware_master_ip` variables in `terraform.tfvars` and run:

```
$ terraform plan \
  ../../platforms/vmware
$ terraform apply \
  ../../platforms/vmware
```
Shortly after running `terraform apply` you should see new master machines on Tectonic console. 

Make sure to add the new Controller nodes' IP addresses in DNS for `tectonic_vmware_controller_domain` variable or Update your Load balancer to include new Controller nodes.

## Known issues and workarounds

See the [troubleshooting][troubleshooting] document for workarounds for bugs that are being tracked

## Delete the cluster

To delete your cluster, run:

```
$ terraform destroy ../../platforms/vmware
```

[account]: https://account.coreos.com
[baremetaldns]: https://coreos.com/tectonic/docs/latest/install/bare-metal/#dns 
[conventions]: ../../conventions.md
[generic]: ../../generic-platform.md
[downloadterraform]: https://www.terraform.io/downloads.html
[vmware]: ../../variables/vmware.md
[vars]: ../../variables/config.md
[troubleshooting]: ../../troubleshooting/faq.md