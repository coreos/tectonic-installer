provider "vsphere" {
  version              = "0.4.2"
  vsphere_server       = "${var.tectonic_vmware_server}"
  allow_unverified_ssl = "${var.tectonic_vmware_sslselfsigned}"
}

resource "vsphere_folder" "tectonic_vsphere_folder" {
  path          = "${var.tectonic_vmware_folder}"
  type          = "${var.tectonic_vmware_type}"
  datacenter_id = "${var.tectonic_vmware_datacenter}"
}