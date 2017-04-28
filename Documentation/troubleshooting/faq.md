# Tectonic Installer FAQ

## License and pull-secret formats

When copying your license and pull-secret from account.coreos.com, be sure to choose the correct format. The license format should be "Raw Format" and the pull-secret should be in the "dockercfg" format.

## Domain name can't be changed

The domain names selected for Tectonic and Controller DNS names during install cannot be easily changed later. If a cluster's domain name must change, set up a new cluster with the new domain name and migrate cluster work to it.

## Safari browser on OSX

Tectonic Installer may fail to download `assets.zip` file during the install due to a known issue in Safari/Webkit. OSX users are advised to use Firefox or Chrome to use Tectonic Installer on OSX machines.

## How can I recover from a Tectonic Identity misconfiguration?

If you have misconfigured Tectonic Identity, it is possible to be temporarily locked out of your cluster. To correct the misconfiguration, use the credentials in the [assets bundle][assets] generated during installation to revert or correct your [user and RBAC configuration][user-management].

## What Services are Installed with Tectonic?

Tectonic Services are the applications that are installed into your cluster. These include:

| Name | Description |
|------|-------------|
| Tectonic Console   | Web management console for Kubernetes and the services themselves |
| Tectonic Identity  | Centralized user management for services on your cluster |
| Prometheus         | Complete cluster monitoring: instrumentation, collection, and querying. |

---

## Community Support Forum

Make sure to check out the [community support forum](https://github.com/coreos/tectonic-forum/issues) to work through issues, report bugs, identify documentation requirements, or put in feature requests.

*If you have any unanswered questions about Tectonic Installer visit [coreos.com/contact][contact]*.


[contact]: https://coreos.com/contact/
