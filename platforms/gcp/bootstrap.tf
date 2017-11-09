locals {
  _dependencies = [
    "${module.masters.instance_group}",
    "${module.etcd.etcd_ip_addresses}",
    "${module.etcd_certs.id}",
    "${module.bootkube.id}",
    "${module.tectonic.id}",
    "${module.flannel_vxlan.id}",
    "${module.calico.id}",
    "${module.canal.id}",
  ]
}

resource "null_resource" "bootstrapper" {
  triggers {
    endpoint     = "${module.network.ssh_master_ip}"
    dependencies = "${join("", concat(flatten(local._dependencies)))}"
  }

  connection {
    host  = "${module.network.ssh_master_ip}"
    user  = "core"
    agent = true
  }

  provisioner "file" {
    when        = "create"
    source      = "./generated"
    destination = "$HOME/tectonic"
  }
}
