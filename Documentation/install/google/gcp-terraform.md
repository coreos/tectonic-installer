# Install Tectonic on Google Cloud Platform with Terraform

Following this guide will deploy a Tectonic cluster within your GCP project.

Generally, the GCP platform templates adhere to the standards defined by the project [conventions][conventions] and [generic platform requirements][generic]. This document aims to document the implementation details specific to Google Cloud Platform.

<p style="background:#d9edf7; padding: 10px;" class="text-info"><strong>Alpha:</strong> These modules and instructions are currently considered alpha. See the <a href="../../platform-lifecycle.md">platform life cycle</a> for more details.</p>

## Prerequsities

 - **DNS** - Ensure that the DNS zone is already created and available in [Cloud DNS][dns] for the project. For example if the `tectonic_base_domain` is set to `kube.example.com` a Cloud DNS managed zone must exist for this domain and the GCP nameservers must be configured for the domain.
 - **Make** - This guide uses `make` to download a customized version of Terraform, which is pinned to a specific version and includes required plugins.
 - **Tectonic Account** - Register for a [Tectonic Account][register], which is free for up to 10 nodes. You will need to provide the cluster license and pull secret below.

## Getting Started

First, clone the Tectonic Installer repository in a convenient location:

```
$ git clone https://github.com/coreos/tectonic-installer.git
$ cd tectonic-installer
```

Download and install [Terraform][terraform] (version 0.9.4 or higher) and
make sure terraform is in your PATH.

Next, get the modules that Terraform will use to create the cluster resources:

```
$ terraform get platforms/google
```

Now we're ready to specify our cluster configuration.

## Customize the deployment

Customizations to the base installation live in `platforms/gcp/terraform.tfvars.example`. Export a variable that will be your cluster identifier:

```
$ export CLUSTER=my-cluster
```

Create a build directory to hold your customizations and copy the example file into it:

```
$ mkdir -p build/${CLUSTER}
$ cp platforms/google/terraform.tfvars.example build/${CLUSTER}/terraform.tfvars
```

Edit the parameters with your GCP details, project id, credentials (see
the [GCP docs][env] for details), region, domain name, license, etc.
[View all of the GCP specific options][gcp-vars] and
[the common Tectonic variables][vars].

## Deploy the cluster

Test out the plan before deploying everything:

```
$ terraform plan -var-file=build/${CLUSTER}/terraform.tfvars platforms/google
```

Next, deploy the cluster:

```
$ terraform apply -var-file=build/${CLUSTER}/terraform.tfvars platforms/google
```

This should run for a little bit, and when complete, your Tectonic cluster should be ready.

If you encounter any issues, check the known issues and workarounds below.

### Access the cluster

The Tectonic Console should be up and running after the containers have downloaded. You can access it at the DNS name configured in your variables file.

Inside of the `/generated` folder you should find any credentials, including the CA if generated, and a kubeconfig. You can use this to control the cluster with `kubectl`:

```
$ export KUBECONFIG=generated/kubeconfig
$ kubectl cluster-info
```

### Delete the cluster

Deleting your cluster will remove only the infrastructure elements created by Terraform. If you selected an existing VPC and subnets, these items are not touched. To delete, run:

```
$ terraform destroy -var-file=build/${CLUSTER}/terraform.tfvars platforms/google
```

### Known issues and workarounds

See the [troubleshooting][troubleshooting] document for work arounds for bugs that are being tracked.

[conventions]: ../../conventions.md
[generic]: ../../generic-platform.md
[dns]: https://cloud.google.com/dns/
[env]: https://cloud.google.com/sdk/docs/authorizing
[register]: https://account.coreos.com/signup/summary/tectonic-2016-12
[account]: https://account.coreos.com
[vars]: ../../variables/config.md
[troubleshooting]: ../../troubleshooting.md
[gcp-vars]: ../../variables/gcp.md
[terraform]: https://www.terraform.io/downloads.html
