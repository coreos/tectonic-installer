provider "vsphere" {
  user           = "${var.tectonic_vmware_username}"
  password       = "${var.tectonic_vmware_password}"
  vsphere_server = "${var.tectonic_vmware_server}"
  allow_unverified_ssl = "${var.tectonic_vmware_sslselfsigned}"
}

resource "vsphere_folder" "tectonic_vsphere_folder" {
  path = "${var.tectonic_vmware_folder}"
  datacenter = "${var.tectonic_vmware_datacenter}"
}