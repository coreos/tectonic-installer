# VMware with Terraform

## Prerequsities

1. The latest Container Linux Stable (1298.6.0 or later) [downloaded and imported into vSphere][booting on vmware].
1. Convert the Container Linux image [into a Virtual Machine template][vmware convert to template]
1. Ensure you have VMware credentials set up, i.e. the [environment variables][terraform vsphere provider] `VSPHERE_USER`, `VSPHERE_PASSWORD`, `VSPHERE_SERVER`, `VSPHERE_ALLOW_UNVERIFIED_SSL` are set or present in `terraform.tfvar` file under build folder.
1. Ensure that DHCP exists in the PortGroup that is targetted for Tectonic installation
1. Current Node discovery requires AWS Route53 hosted public domain, ensure that [Terraform AWS provider integration][terraform aws provider] is setup

## Getting Started

First, download Terraform with via `make`. This will download the pinned Terraform binary and modules:

```
$ cd tectonic-installer
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
$ terraform get platforms/vmware
```

Configure your AWS credentials.

```
$ export AWS_ACCESS_KEY_ID=
$ export AWS_SECRET_ACCESS_KEY=
```

An AWS region is required even-though Route53 is not region specific.

```
$ export AWS_REGION=
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

Tectonic Installer for VMware deploys with [Kubneretes vSphere extensions][kubernetes vmware], which allow storage and metadata integations. See [vSphere Examples][vsphere examples] to create a POD with VMFS/VMDK integration.

## Delete the cluster

To delete your cluster, run:

```
$ PLATFORM=vmware CLUSTER=my-cluster make destroy
```



[booting on vmware]: [https://coreos.com/os/docs/latest/booting-on-vmware.html]
[vmware convert to template]: [https://pubs.vmware.com/vsphere-51/index.jsp?topic=%2Fcom.vmware.vsphere.vm_admin.doc%2FGUID-846238E4-A1E3-4A28-B230-33BDD1D57454.html]
[terraform vsphere provider]: [https://www.terraform.io/docs/providers/vsphere/index.html]
[terraform aws provider]: [https://www.terraform.io/docs/providers/aws/index.html]
[account]: https://account.coreos.com
[bcrypt]: https://github.com/coreos/bcrypt-tool/releases/tag/v1.0.0
[vsphere examples]: https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/vsphere
[kubernetes vmware]: https://kubernetes.io/docs/getting-started-guides/vsphere/