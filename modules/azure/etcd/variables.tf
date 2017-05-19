// Location is the Azure Location (East US, West US, etc)
variable "location" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

// VM Size name
variable "vm_size" {
  type = "string"
}

variable "cl_channel" {
  type = "string"
}

// Count of etcd nodes to be created.
variable "etcd_count" {
  type = "string"
}

variable "external_endpoints" {
  type = "list"
}

// The base DNS domain of the cluster.
// Example: `azure.dev.coreos.systems`
variable "base_domain" {
  type = "string"
}

// The name of the cluster.
variable "cluster_name" {
  type = "string"
}

variable "public_ssh_key" {
  type = "string"
}

variable "virtual_network" {
  type = "string"
}

variable "subnet" {
  type = "string"
}

variable "container_image" {
  type = "string"
}

data "null_data_source" "consts" {
  inputs = {
    instance_count = "${length(var.external_endpoints) == 0 ? var.etcd_count : 0}"
  }
}
