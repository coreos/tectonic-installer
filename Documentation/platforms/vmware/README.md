# VMware with Terraform

## Prerequsities

1. Download the latest Container Linux Stable (1298.6.0 or later) from; https://coreos.com/os/docs/latest/booting-on-vmware.html.
1. Import `coreos_production_vmware_ova.ova` into vCenter.
1. Resize the Virtual Machine Disk size to 30 GB
1. Convert the Container Linux image into a Virtual Machine template.
1. Pre-Allocated IP addresses for the cluster and pre-create DNS records


## DNS and IP address allocation

Tectonic Virtual Machine named follow the $clustername-etcd-$instancenumber, $clustername-master-$instancenumber, $clustername-worker-$instancenumber syntax. The manifests for VMware within this repository assume static allocation of IP Addresses.

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


## Getting Started

First, download Terraform with via `make`. This will download the pinned Terraform binary and modules:

```
$ cd tectonic-installer
$ make terraform-download
```

After downloading, you will need to source this new binary in your `$PATH`. This is important, especially if you have another version of Terraform installed. Run this command to add it to your path:

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
$ terraform get platforms/vmware
```

Now we're ready to specify our cluster configuration.

## Customize the deployment

Use this example to customize your cluster configuration. A few fields require special consideration:

 - **tectonic_base_domain** - domain name that is set up with in a resource group, as described in the prerequisites.
 - **tectonic_pull_secret_path** - path on disk to your downloaded pull secret. You can find this on your [Account dashboard][account].
 - **tectonic_license_path** - path on disk to your downloaded Tectonic license. You can find this on your [Account dashboard][account].
 - **tectonic_admin_password_hash** - generate a hash with the [bcrypt-hash tool][bcrypt] that will be used for your admin user.
 - **build/<cluster>/terraform.tfvars** - can be modified from the sample in platform/vmware/terraform.tfvars.example

## Deploy the cluster

Test out the plan before deploying everything:

```
$ PLATFORM=vmware CLUSTER=my-cluster make plan
```

Next, deploy the cluster:

```
$ PLATFORM=vmware CLUSTER=my-cluster make apply
```

This should run for a little bit, and when complete, your Tectonic cluster should be ready on: https://$tectonic_cluster_name.$tectonic_base_domain. You can use the `kubeconfig` file in build/<cluster>/generated folder.

If you encounter any issues, please file an issue with the repository.

## VMware vSphere Provider for Kubernetes

Tectonic Installer for VMware deploys with [Kubneretes vSphere extensions][kubernetesvmware], which allow storage and metadata integations. See [vSphere Examples][vsphereexamples] to create a POD with VMFS/VMDK integration.

## Delete the cluster

To delete your cluster, run:

```
$ PLATFORM=vmware CLUSTER=my-cluster make destroy
```

[terraformawsprovider]: [https://www.terraform.io/docs/providers/aws/index.html]
[account]: https://account.coreos.com
[bcrypt]: https://github.com/coreos/bcrypt-tool/releases/tag/v1.0.0
[vsphereexamples]: https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/vsphere
[kubernetesvmware]: https://kubernetes.io/docs/getting-started-guides/vsphere/