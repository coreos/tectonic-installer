# Install Tectonic on Bare-Metal with Terraform

Following this guide will deploy a Tectonic cluster on virtual or physical hardware.

<p style="background:#d9edf7; padding: 10px;" class="text-info"><strong>Alpha:</strong>These instructions are currently considered alpha. See the <a href="../../platform-lifecycle.md">platform life cycle</a> for more details.</p>

## Prerequsities

* Matchbox [v0.6.0](https://github.com/coreos/matchbox/releases) installation with the gRPC API enabled. See [installation](https://coreos.com/matchbox/docs/latest/deployment.html).
* Matchbox TLS client credentials
* PXE network boot environment with DHCP, TFTP, and DNS services. See [network-setup](https://coreos.com/matchbox/docs/latest/network-setup.html).
* DNS records for the Kubernetes controller(s) and Tectonic Ingress worker(s). See [DNS](https://coreos.com/tectonic/docs/latest/install/bare-metal#networking).
* Machines with BIOS options set to boot from disk normally, but PXE prior to installation.
* Machines with known MAC addresses and stable domain names.
* make,go,npm - This guide uses `make`, `go`, and `npm` to build the Tectonic Installer.
* Tectonic Account - Register for a [Tectonic Account][register], which is free for up to 10 nodes. You will need to provide the cluster license and pull secret below.

## Getting Started

First, clone the Tectonic Installer repository in a convenient location:

```
$ git clone https://github.com/coreos/tectonic-installer.git
$ cd tectonic-installer
```

Build the Tectonic Installer:

```
$ (cd installer && make build)
```

Initialize the Terraform configuration with Installer's location and export the path to that configuration:

```
$ INSTALLER_PATH=$(pwd)/installer/bin/linux/installer # Edit the platform name.
$ sed "s|<PATH_TO_INSTALLER>|$INSTALLER_PATH|g" terraformrc.example > .terraformrc
$ export TERRAFORM_CONFIG=$(pwd)/.terraformrc
```

Now we're ready to specify our cluster configuration.

## Customize the deployment

Create a build directory to hold your customizations and copy the example file into it:

```
$ export CLUSTER=my-cluster
$ mkdir -p build/${CLUSTER}
$ cp examples/terraform.tfvars.metal build/${CLUSTER}/terraform.tfvars
```

Customizations should be made to `build/${CLUSTER}/terraform.tfvars`. Edit the following variables to correspond to your matchbox installation:

* `tectonic_matchbox_http_endpoint`
* `tectonic_matchbox_rpc_endpoint`
* `tectonic_matchbox_client_cert`
* `tectonic_matchbox_client_key`
* `tectonic_matchboc_ca`

Edit additional variables to specify DNS records, list machines, and set a password and SSH key.

## Deploy the cluster

Test out the plan before deploying everything:

```
$ terraform plan -var-file=build/${CLUSTER}/terraform.tfvars platforms/metal
```

Next, deploy the cluster:

```
$ terraform apply -var-file=build/${CLUSTER}/terraform.tfvars platforms/metal
```

This will write machine profiles and matcher groups to the matchbox service.

## Power On

Power on the machines with `ipmitool` or `virt-install`. Machines will PXE boot, install Container Linux to disk, and reboot.

```
ipmitool -H node1.example.com -U USER -P PASS power off
ipmitool -H node1.example.com -U USER -P PASS chassis bootdev pxe
ipmitool -H node1.example.com -U USER -P PASS power on
```

Terraform will try to copy credentials to the nodes and run some commands. This can fail until the disk installation and reboot has completed.

Run `terraform apply` until all tasks complete. Your Tectonic cluster should be ready.

If you encounter any issues, check the known issues and workarounds below.

### Access the cluster

The Tectonic Console should be up and running after the containers have downloaded. You can access it at the DNS name configured in your variables file.

Inside of the `/generated` folder you should find any credentials, including the CA if generated, and a kubeconfig. You can use this to control the cluster with `kubectl`:

```
$ export KUBECONFIG=generated/auth/kubeconfig
$ kubectl cluster-info
```

### Delete the cluster

Delete your cluster to delete the matchbox profiles and matcher groups. Deletion will not modify or power off your machines.

```
$ terraform destroy -var-file=build/${CLUSTER}/terraform.tfvars platforms/metal
```

### Known issues and workarounds

See the [troubleshooting][troubleshooting] document for work arounds for bugs that are being tracked.

[conventions]: ../../conventions.md
[generic]: ../../generic-platform.md
[register]: https://account.coreos.com/signup/summary/tectonic-2016-12
[account]: https://account.coreos.com
[vars]: ../../variables/config.md
[troubleshooting]: ../../troubleshooting.md
