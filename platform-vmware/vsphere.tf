# Configure the VMware vSphere Provider
provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"
  # if you have a self-signed cert
  allow_unverified_ssl = "${var.vsphere_sslselfsigned}"  
}

# Create folder
resource "vsphere_folder" "tectonic-folder" {
  path = "${var.cluster_name}"
  datacenter = "${var.vsphere_datacenter}"
}
