# Tectonic Installer for DigitalOcean
This is Tectonic Installer for the [DigitalOcean](http://digitalocean.com/) hosting platform.
Use this guide to bootstrap a Tectonic cluster on with your DigitalOcean account.

## Prerequisites

- **Terraform:** >= v0.10.7
- **Make:** You should install the traditional [Make](https://www.gnu.org/software/make/)
build tool.
- **Docker:** For the time being, you need Docker installed in addition to Terraform, in order
to perform certain tasks.
- **Tectonic Account:** Register for a [Tectonic Account](https://coreos.com/tectonic), which is
free for up to 10 nodes. Download the Tectonic license as tectonic-license.txt and the pull secret
as config.json.
- **DigitalOcean:**
  - Obtain an API token by going to DigitalOcean's
  [API page](https://cloud.digitalocean.com/settings/api/tokens) and click *Generate New Token*.
  Make note of it for later.
  - Obtain a Spaces key/secret pair, again by going to DigitalOcean's API page and click
  *Generate New Key* in the _Spaces Access Keys_ section. Make note of it for later.
  - Ensure that the base domain for the cluster is already created for your DigitalOcean
account and listed among your [domains](https://cloud.digitalocean.com/networking/domains).

## Getting Started

First, clone the Tectonic Installer repository:

```
$ git clone https://github.com/coreos/tectonic-installer.git
$ cd tectonic-installer
```

Then, create the build tree for your cluster:

```
$ CLUSTER=<cluster-name> PLATFORM=digitalocean make localconfig
```

Install the Tectonic license file (tectonic-license.txt) and the pull secret (config.json):

```
$ cp tectonic-license.txt config.json build/<cluster-name>/
```

## Customize the Cluster

You may change the parameters of the cluster bootstrapping via the file
`build/<cluster-name>/terraform.tfvars`, which is
[automatically read](https://www.terraform.io/docs/configuration/variables.html) by Terraform to
populate variables.

Edit the parameters as you need, bearing in mind that some have no defaults and you must
specify values for them. You should substitute the DigitalOcean API token, Spaces key ID and
secret for the variables `tectonic_do_token`, `tectonic_do_spaces_access_key_id` and
`tectonic_do_spaces_secret_access_key` respectively. Additionally, you need to get the ID
of the DigitalOcean SSH key you wish to use, for example like this:
`curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $API_TOKEN" https://api.digitalocean.com/v2/account/keys | jq '.ssh_keys[0].id'`.
Substitute the key ID for `tectonic_do_ssh_keys`.

## Deploy the cluster

Test the plan before deploying everything:

```
$ CLUSTER=<cluster-name> PLATFORM=digitalocean make plan
```

Next, bootstrap the cluster:

```
$ CLUSTER=<cluster-name> PLATFORM=digitalocean make apply
```

This should run for a while, and when complete, your Tectonic cluster should be ready.

Tectonic Installer generates a kubeconfig file, which allows you to access your newly created
cluster via kubectl: `build/<cluster-name>/generated/auth/kubeconfig`. For example, you
can inspect the state of your clusters' pods with the following command:
`KUBECONFIG=build/<cluster-name>/generated/auth/kubeconfig kubectl get pods --all-namespaces`.
When every pod is listed as ready, your cluster should be finished bootstrapping.

### Access the cluster

After bootstrapping, you can access the Tectonic Console at `https://<cluster-name>.<base-domain>`.

### Delete the cluster

```
$ CLUSTER=<cluster-name> PLATFORM=digitalocean make destroy
```

## Known Issues

- For technical reasons, only one master is created.

- This is a non stable version currently under heavy development. It is not yet covered by a deprecation policy and may be subject to backward-incompatible changes.

## Developer Notes

### etcd

#### Testing
In order to test the etcd cluster, SSH into one of the etcd nodes and issue the following command
(setting `$CLUSTER_NAME` and `$DOMAIN_NAME` correspondingly):
`sudo ETCDCTL_API=3 etcdctl --cacert=/etc/ssl/etcd/ca.crt --cert=/etc/ssl/etcd/client.crt --key=/etc/ssl/etcd/client.key --endpoints=https://$CLUSTER_NAME-etcd-0.$DOMAIN_NAME:2379 endpoint health`.
This should report that the cluster is healthy.

### Masters
There is currently only one master being created, for reasons of simplicity. It receives the
DNS name `<cluster-name>-api.<domain-name>`, so that it can be contacted as the API server of the
Kubernetes cluster, but also the DNS name `<cluster-name>-master-<index>.<domain-name>`.

### Workers
We create a number of workers corresponding to the variable `tectonic_worker_count`. Each of
these receives a DNS name `<cluster-name>-worker-<index>.<domain-name>`.

### Host Name Resolution
Every master and worker node is configured, via /etc/systemd/resolved.conf, to resolve hostnames
within the base domain. This is because Kubernetes expects to be able to resolve the unqualified
hostnames of its nodes, and will fail otherwise.
