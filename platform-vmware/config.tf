variable "vsphere_server" {
  type    = "string"
  default = "192.168.1.120"
}

variable "vsphere_datacenter" {
  type    = "string"
  default = "nyc"
}

variable "vsphere_datastore" {
  type    = "string"
  default = "datastore2"
}

variable "vsphere_datastore_path" {
  type    = "string"
  default = "tectonic"
}

variable "cluster_name" {
  type    = "string"
  default = "demo"
}

variable "master_name" {
  type    = "string"
  default = "demo-master"
}

variable "etcd_name" {
  type    = "string"
  default = "demo-etcd"
}

variable "worker_hostname" {
  type    = "string"
  default = "demo-worker"
}

variable "coreos_template" {
  type    = "string"
  default = "coreos_production_vmware_ova"
}

variable "tectonic_network" {
  type    = "string"
  default = "VM Network"
}

variable "tectonic_cluster" {
  type    = "string"
  default = "cluster"
}

variable "vsphere_sslselfsigned" {  
  default = true
}

variable "tectonic_version" {
  type    = "string"
  default = "v1.5.2_coreos.1"
}

variable "master_count" {
  type    = "string"
  default = "1"
}

variable "worker_count" {
  type    = "string"
  default = "1"
}

variable "etcd_count" {
  type    = "string"
  default = "1"
}

variable "base_domain" {
  type    = "string"
  default = "aws.alekssaul.com"
}