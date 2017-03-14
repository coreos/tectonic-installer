variable "vsphere_user" {
  type    = "string"
}

variable "vsphere_password" {
  type    = "string"
}

# Configure the VMware vSphere Provider
provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.tectonic_vsphere_server}"
  # if you have a self-signed cert
  allow_unverified_ssl = "${var.vsphere_sslselfsigned}"  
}

# Create folder
resource "vsphere_folder" "tectonic-folder" {
  path = "${var.tectonic_cluster_name}"
  datacenter = "${var.tectonic_vsphere_datacenter}"
}

# vCenter server IP / DNS ex: vcenter.company.com
variable "tectonic_vsphere_server" {
  type    = "string"  
}

# vSphere datacenter
variable "tectonic_vsphere_datacenter" {
  type    = "string"
  default = "nyc"
}

# vSphere datastore to provision
variable "tectonic_vsphere_datastore" {
  type    = "string"  
}

variable "tectonic_vsphere_datastore_path" {
  type    = "string"
  default = "tectonic"
}

# CoreOS Container Linux Virtual Machine Template
variable "tectonic_vsphere_coreos_template" {
  type    = "string"
  default = "coreos_production_vmware_ova"
}

# VM Network
variable "tectonic_vsphere_network" {
  type    = "string"
  default = "VM Network"
}

# vSphere Cluster
variable "tectonic_vsphere_cluster" {
  type    = "string"
  default = "cluster"
}

# Self Signed SSL / insecure connection
variable "vsphere_sslselfsigned" {  
  default = true
}