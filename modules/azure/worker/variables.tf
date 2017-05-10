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

// Count of worker nodes to be created.
variable "worker_count" {
  type = "string"
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

variable "nsg_id" {
  type = "string"
}

variable "virtual_network" {
  type = "string"
}

variable "subnet" {
  type = "string"
}

variable "custom_data" {
  type = "string"
}

variable "public_ssh_key" {
  type = "string"
}
