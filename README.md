# Tectonic Installer

Tectonic is built on pure-upstream Kubernetes but has an opinion on the best way to install and run a Kubernetes cluster. This project helps you install a Kubernetes cluster the "Tectonic Way". It provides good defaults, enables install automation, and is customizable to meet your infrastructure needs.

## Releasing

- Test branch in kubernetes dev environment
- Create a PR to master
- Create a Tag / Release with the version name (1.13.5)
- Update [Makefile](https://github.com/conde-nast-international/cnid-infrastructure-core-platform/blob/master/Makefile#L2) to the new release

## Getting Started



**Terraform**

The Tectonic Installer releases include a build of [Terraform](https://terraform.io). See the [Tectonic Installer release notes][release-notes] for information about which Terraform versions are compatible.

The [latest Terraform binary](https://www.terraform.io/downloads.html) may not always work as Tectonic Installer, which sometimes relies on bug fixes or features not yet available in the official Terraform release.

#### Common Usage

**Choose your platform**

First, set the `PLATFORM=` environment variable. This example will use `PLATFORM=azure`.

- `PLATFORM=openstack` [OpenStack via Terraform][openstack-tf] [[**alpha**][platform-lifecycle]]
- `PLATFORM=vmware` [VMware via Terraform][vmware-tf] [[**alpha**][platform-lifecycle]]

**Initiate the Cluster Configuration**

Use `make` to create a new directory `build/<cluster-name>` to hold all module references, Terraform state files, and custom variable files.

```
PLATFORM=azure CLUSTER=my-cluster make localconfig
```

**Configure Cluster**

Set variables in the `build/<cluster-name>/terraform.tfvars` file as needed. Available variables are found in the `platforms/<PLATFORM>/config.tf` and `platforms/<PLATFORM>/variables.tf` files.

Examples for each platform can be found in [the examples directory](examples/).

**Terraform Lifecycle**

`plan`, `apply`, and `destroy` are provided as `make` targets to ease the build directory and custom binary complexity.

```
PLATFORM=azure CLUSTER=my-cluster make plan
```

```
PLATFORM=azure CLUSTER=my-cluster make apply
```

```
PLATFORM=azure CLUSTER=my-cluster make destroy
```

#### Tests

See [tests/README.md](tests/README.md).
