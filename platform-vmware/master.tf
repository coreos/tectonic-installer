resource "vsphere_virtual_machine" "master-vm"   {
  name   = "${var.master_name}"
  folder = "${vsphere_folder.tectonic-folder.path}"
  datacenter = "${var.vsphere_datacenter}"
  cluster = "${var.tectonic_cluster}"
  vcpu   = 1
  memory = 2048

  network_interface {
    label = "${var.tectonic_network}"
  }

  disk {
    datastore = "${var.vsphere_datastore}"  
    template = "${var.coreos_template}"
  }

  custom_configuration_parameters {
    guestinfo.coreos.config.data.encoding = "base64"
    guestinfo.coreos.config.data = "${base64encode(ignition_config.master.*.rendered[count.index])}"
  }
}

resource "null_resource" "copy_assets" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(" ", vsphere_virtual_machine.master-vm.*.id)}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    user        = "core"
    private_key = "${tls_private_key.core.private_key_pem}"
    host        = "${element(vsphere_virtual_machine.master-vm.*.network_interface.0.ipv4_address, 0)}"    
  }

  provisioner "file" {
    source      = "${path.cwd}/assets"
    destination = "/home/core/assets"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/assets /opt/bootkube/",
      "sudo chmod a+x /opt/bootkube/assets/bootkube-start",
      "sudo systemctl start bootkube",
    ]
  }
}