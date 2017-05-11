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

// Count of master nodes to be created.
variable "master_count" {
  type = "string"
}

variable "custom_data" {
  type = "string"
}

variable "availability_set_name" {
  type = "string"
}

variable "public_ssh_key" {
  type = "string"
}

variable "use_custom_fqdn" {
  default = true
}

variable "public_ip_type" {
  type = "string"
}
