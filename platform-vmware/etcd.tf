resource "vsphere_virtual_machine" "etcd_node"   {
  name   = "${var.etcd_name}"
  folder = "${vsphere_folder.tectonic-folder.path}"
  datacenter = "${var.vsphere_datacenter}"
  cluster = "${var.tectonic_cluster}"
  vcpu   = 1
  memory = 1024

  network_interface {
    label = "${var.tectonic_network}"
  }

  disk {
    datastore = "${var.vsphere_datastore}"  
    template = "${var.coreos_template}"
  }

  custom_configuration_parameters {
    guestinfo.coreos.config.data.encoding = "base64"
    guestinfo.coreos.config.data = "${base64encode(ignition_config.etcd.*.rendered[count.index])}"
  }
}