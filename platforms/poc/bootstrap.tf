resource "local_file" "bootstrap_ign" {
  filename = "./generated/bootstrap.ign"
  content  = "${data.ignition_config.bootstrap.rendered}"
}

resource "local_file" "master_ign" {
  count = "${length(var.tectonic_metal_controller_names)}"

  filename = "./generated/master${count.index+1}.ign"
  content  = "${data.ignition_config.master.*.rendered[count.index]}"
}

resource "local_file" "worker_ign" {
  count = "${length(var.tectonic_metal_worker_names)}"

  filename = "./generated/worker${count.index+1}.ign"
  content  = "${data.ignition_config.worker.*.rendered[count.index]}"
}

resource "null_resource" "kubeconfig" {
  depends_on = ["module.bootkube"]

  connection {
    type    = "ssh"
    host    = "bootstrap.k8s"
    user    = "core"
    timeout = "60m"
  }

  provisioner "file" {
    content     = "${module.bootkube.kubeconfig}"
    destination = "$HOME/kubeconfig"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig",
    ]
  }
}

module "bootstrapper" {
  source = "../../modules/bootstrap-ssh"

  _dependencies = [
    "${module.bootkube.id}",
    "${module.tectonic.id}",
    "${module.flannel_vxlan.id}",
    "${local_file.bootstrap_ign.id}",
    "${local_file.master_ign.*.id}",
    "${local_file.worker_ign.*.id}",
  ]

  bootstrapping_host = "bootstrap.k8s"
}
