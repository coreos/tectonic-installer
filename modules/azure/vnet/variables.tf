variable "tectonic_azure_external_vnet_id" {
  type    = "string"
  default = ""
}

variable "tectonic_azure_vnet_cidr_block" {
  type    = "string"
  default = "10.0.0.0/16"
}

variable "tectonic_cluster_name" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "vnet_cidr_block" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "external_vnet_name" {
  type    = "string"
  default = ""
}

variable "external_master_subnet_id" {
  type    = "string"
  default = ""
}

variable "external_worker_subnet_id" {
  type    = "string"
  default = ""
}

#variable "etcd_lb_ip" {
#  type = "string"
#}

variable "etcd_cidr" {
  type    = "string"
  default = ""
}

variable "master_cidr" {
  type    = "string"
  default = ""
}

variable "worker_cidr" {
  type    = "string"
  default = ""
}

variable "ssh_network_internal" {
  type    = "string"
  default = ""
}

variable "ssh_network_external" {
  type    = "string"
  default = ""
}

variable "external_nsg_rsg_name" {
  type = "string"
}

variable "external_etcd_nsg_name" {
  type    = "string"
  default = ""
}

variable "external_api_nsg_name" {
  type    = "string"
  default = ""
}

variable "external_master_nsg_name" {
  type    = "string"
  default = ""
}

variable "external_worker_nsg_name" {
  type    = "string"
  default = ""
}

variable "create_api_nsg_rules" {
  default = false
}

variable "create_etcd_nsg_rules" {
  default = false
}

variable "create_master_nsg_rules" {
  default = false
}

variable "create_worker_nsg_rules" {
  default = false
}
