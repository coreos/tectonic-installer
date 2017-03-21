# Tectonic Installer

Tectonic is built on pure-upstream Kubernetes but has an opinion on the best way to install and run a Kubernetes cluster. This project helps you install a Kubernetes cluster the "Tectonic Way". It provides good defaults, enables install automation, and is customizable to meet your infrastructure needs.

Goals of the project:

- Installation of [Self-Hosted Kubernetes Cluster](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/self-hosted-kubernetes.md)
- Secure by default (use TLS, RBAC by default, OIDC AuthN, etcd)
- Automatable install process for scripts and CI/CD
- Deploy Tectonic on any infrastructure (Amazon, Azure, OpenStack, GCP, etc)
- Runs Tectonic on any OS (Container Linux, RHEL, CentOS, etc)
- Customizable and modular (change DNS providers, security settings, etc)
- HA by default (deploy all Kubernetes components HA, use etcd Operator)

Checkout the [ROADMAP](ROADMAP.md) for details on where the project is headed.

## Getting Started

### Step 1: Sign-up for the Tectonic Free Tier

Sign-up for the [Tectonic Free Tier](https://coreos.com/tectonic).

*Note:* We will make this project flexible enough in the coming weeks to just install Kubernetes without the additional Tectonic Components. Please help make this happen or follow this issue.

### Step 2: Download the Tectonic installer.

```
wget https://releases.tectonic.com/tectonic-X.Y.Z-tectonic.N.tar.gz
tar xzvf tectonic-X.Y.Z-tectonic.N.tar.gz
```

### Step 2: Choose a Platform

- [AWS Cloud Formation](https://coreos.com/tectonic/docs/latest/install/aws/) [[**stable**][platform-lifecycle]]
- [Baremetal](https://coreos.com/tectonic/docs/latest/install/bare-metal/) [[**stable**][platform-lifecycle]]
- [AWS via Terraform](aws/README.md) [[**alpha**][platform-lifecycle]]
- [Azure via Terraform](azure/README.md) [[**alpha**][platform-lifecycle]]
- [OpenStack via Terraform](openstack/README.md) [[**alpha**][platform-lifecycle]]
- [VMware](vmware/README.md) [[**alpha**][platform-lifecycle]]

Note: This repo does not yet have all Tectonic Installer code imported. This will happen over the coming weeks as we are able to move some of the surrounding infrastructure public as well. This notice will be removed once the AWS and Baremetal graphical installer code has been imported.
