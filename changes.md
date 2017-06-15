# Tectonic Changelog

## Tectonic 1.6.4-tectonic.1 (2017-06-06)

Tectonic Installer has improved the stability and user experience of using Terraform to install Tectonic.

* (add general items)

## Console

* (add console items)

## Dex

* (add dex items)

## Bug Fixes

* (add bug fixes)

## Known Issues

* Tectonic Identity performance issue with OIDC ([more info](Documentation/troubleshooting/known-issues.md#tectonic-identity-performance-issue-with-oidc))
* Issues running Terraform commands when using "Launch etcd for me" option ([more info](https://github.com/coreos/tectonic-installer/blob/known-issues/Documentation/troubleshooting/known-issues.md#issues-running-terraform-commands-when-using-launch-etcd-for-me-option))

## Tectonic 1.6.2-tectonic.1 (2017-04-10)

Tectonic now uses Terraform for cluster installation. This supports greater customization of environments, enables scripted installs and generally makes it easier to manage the lifecycle of multiple clusters.

* Switches provisioning methods on AWS & Bare-Metal to Terraform exclusively.
* Adds support for customizing the Tectonic infrastructure via Terraform.
* Introduces experimental support for self-hosted etcd using its operator, and associated UI.
* Adds Container Linux Update Operator(CLUO).
* Updates to Kubernetes v1.6.2.
* Updates to bootkube v0.4.2.
* GUI Installer with Terraform on AWS and bare-metal.
* Segregates control-plane / user workloads to master / worker nodes respectively.
* API server-to-etcd communication is secured over TLS.
* Removes locksmithd, etcd-gateway.
* Enables audit-logs for the API Server.
* Removes final manual installation step of copying over assets folder.

## Console

Role-based Access Control screens have been redesigned to make it easier to securely grant access to your clusters.

* Updates to Console v1.5.2.
* Adds binding name column to Role Bindings list pages
* Adds role binding name to fields searched by text filter
* Adds RBAC YAML editor
* Adds etcd cluster management pages

## Dex

* Updates to Dex v2.4.1.
* Adds support for login through SAML and GitHub Enterprise.

## Bug Fixes

* Fixes an issue where new nodes started automatically by auto-scalers would start with an outdated version of kubelet.
