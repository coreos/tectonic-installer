# Known issues in Tectonic

The following is a list of confirmed issues or bugs in Tectonic, that will be fixed in future versions. Issues will be marked 'resolved' and listed in the release notes when appropriate.

## Tectonic Identity performance issue with OIDC

**Version:** [Tectonic 1.6.2-tectonic.1](https://coreos.com/tectonic/releases/#1.6.2-tectonic.1)

**Status:** open

**Issue:**

Tectonic Identity, which uses the [dex open source project](https://github.com/coreos/dex), has a known resource issue causing latency in authentication requests. This issue is possibly related to how the Go runtime communicates the max number of CPUs to dex. Read more on the [Github issue](https://github.com/coreos/tectonic-installer/issues/801). 

## Issues running Terraform commands when using "Launch etcd for me" option

**Version:** [Tectonic 1.6.2-tectonic.1](https://coreos.com/tectonic/releases/#1.6.2-tectonic.1)

**Status:** open

**Issue:**

An [upstream Terraform bug](https://github.com/hashicorp/terraform/pull/13793) will cause unexpected results when you run Terraform commands, such as `plan` then `apply` then `destroy`.

You will encounter this if following two conditions are true:
 - Using etcd on VMs (not using the etcd-operator)
 - etcd count is greater than 1 (highly available)

If you encounter this issue, you will see the following log output:

```
Error refreshing state: 2 error(s) occurred:

* module.etcd.data.ignition_config.etcd[2]: index 2 out of range for list data.ignition_file.node_hostname.*.id (max 1) in:

${data.ignition_file.node_hostname.*.id[count.index]}
* module.etcd.data.ignition_config.etcd[1]: index 1 out of range for list data.ignition_systemd_unit.etcd3.*.id (max 1) in:

${data.ignition_systemd_unit.etcd3.*.id[count.index]}
```

**Workaround:**

Download and use this [customized Terraform binary](https://github.com/coreos/terraform/releases/tag/v0.9.6-fcdf494) that will allow you to run commands after your cluster is booted.

A future Tectonic release will update to Terraform 0.9.6, which will contain the bug fix and allow for normal operation.
