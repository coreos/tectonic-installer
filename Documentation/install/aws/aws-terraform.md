# Install Tectonic on AWS with Terraform

Following this guide will deploy a Tectonic cluster within your AWS account. This document is primarily meant for users to bring up the tectonic installer manually. To install Tectonic on AWS with a graphical installer refer [this][aws-gui].

Generally, the AWS platform templates adhere to the standards defined by the project [conventions][conventions] and [generic platform requirements][generic]. This document aims to document the implementation details specific to the AWS platform.

<p style="background:#d9edf7; padding: 10px;" class="text-info"><strong>Alpha:</strong> These modules and instructions are currently considered alpha. See the <a href="../../platform-lifecycle.md">platform life cycle</a> for more details.</p>

## Prerequsities

* **DNS**: Ensure that the DNS zone is already created and available in Route 53 for the account. For example if the `tectonic_base_domain` is set to `kube.example.com` a Route 53 zone must exist for this domain and the AWS nameservers must be configured for the domain.
* **Tectonic Account**: Register for a [Tectonic Account][register], which is free for up to 10 nodes. You will need to provide the cluster license and pull secret below.

## Getting Started

### Download and extract Tectonic Installer

Open a new terminal, and run the following commands to download and extract Tectonic Installer.

```bash
$ curl -O https://releases.tectonic.com/tectonic-1.6.2-tectonic.1.tar.gz # download
$ tar xzvf tectonic-1.6.2-tectonic.1.tar.gz # extract the tarball
$ cd tectonic
```

### Initialize and configure Terraform

Start by setting the `INSTALLER_PATH` to the location of your platform's Tectonic installer. The platform should either be `darwin`, `linux`, or `windows`.

```bash
$ export INSTALLER_PATH=$(pwd)/tectonic-installer/darwin/installer # Edit the platform name.
```

Make a copy of the Terraform configuration file for our system. Do not share this configuration file as it is specific to your machine.

```bash
$ sed "s|<PATH_TO_INSTALLER>|$INSTALLER_PATH|g" terraformrc.example > .terraformrc
$ export TERRAFORM_CONFIG=$(pwd)/.terraformrc
```

Next, get the modules that Terraform will use to create the cluster resources:

```bash
$ terraform get platforms/aws
```

Configure your AWS credentials. See the [AWS docs][env] for details.

```bash
$ export AWS_ACCESS_KEY_ID=
$ export AWS_SECRET_ACCESS_KEY=
```

Set your desired region:

```bash
$ export AWS_REGION=
```

Next, specify the cluster configuration.

## Customize the deployment

Customizations to the base installation live in `platforms/aws/terraform.tfvars.example`. Export a variable that will be your cluster identifier:

```bash
$ export CLUSTER=my-cluster
```

Create a build directory to hold your customizations and copy the example file into it:

```bash
$ mkdir -p build/${CLUSTER}
$ cp examples/terraform.tfvars.aws build/${CLUSTER}/terraform.tfvars
```

Edit the parameters with your AWS details, domain name, license, etc. [View all of the AWS specific options][aws-vars] and [the common Tectonic variables][vars].

## Deploy the cluster

Test out the plan before deploying everything:

```bash
$ terraform plan -var-file=build/${CLUSTER}/terraform.tfvars platforms/aws
```

Next, deploy the cluster:

```bash
$ terraform apply -var-file=build/${CLUSTER}/terraform.tfvars platforms/aws
```

This should run for a little bit, and when complete, your Tectonic cluster should be ready.

### Access the cluster

The Tectonic Console should be up and running after the containers have downloaded. You can access it at the DNS name configured in your variables file.

Inside of the `/generated` folder you should find any credentials, including the CA if generated, and a kubeconfig. You can use this to control the cluster with `kubectl`:

```bash
$ export KUBECONFIG=generated/auth/kubeconfig
$ kubectl cluster-info
```

### Delete the cluster

Deleting your cluster will remove only the infrastructure elements created by Terraform. If you selected an existing VPC and subnets, these items are not touched. To delete, run:

```bash
$ terraform destroy -var-file=build/${CLUSTER}/terraform.tfvars platforms/aws
```

### Known issues and workarounds

See the [troubleshooting][troubleshooting] document for workarounds for bugs that are being tracked.

[conventions]: ../../conventions.md
[generic]: ../../generic-platform.md
[env]: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-environment
[register]: https://account.coreos.com/signup/summary/tectonic-2016-12
[account]: https://account.coreos.com
[vars]: ../../variables/config.md
[troubleshooting]: ../../troubleshooting.md
[aws-vars]: ../../variables/aws.md
[aws-gui]: https://coreos.com/tectonic/docs/latest/install/aws/index.html
[terraform]: https://www.terraform.io/downloads.html
