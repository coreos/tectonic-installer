resource "vsphere_virtual_machine" "worker-vm"   {
  name   = "${var.tectonic_cluster_name}-worker-node-${count.index}"
  folder = "${vsphere_folder.tectonic-folder.path}"
  datacenter = "${var.tectonic_vsphere_datacenter}"
  cluster = "${var.tectonic_vsphere_cluster}"
  vcpu   = 2
  memory = 4096

  network_interface {
    label = "${var.tectonic_vsphere_network}"
  }

  disk {
    datastore = "${var.tectonic_vsphere_datastore}"  
    template = "${var.tectonic_vsphere_coreos_template}"
  }

  custom_configuration_parameters {
    guestinfo.coreos.config.data.encoding = "base64"
    guestinfo.coreos.config.data = "${base64encode(ignition_config.worker.*.rendered[count.index])}"
  }
}   