// Location is the Azure Location (East US, West US, etc)
variable "location" {
  type = "string"
}

variable "resource_group_name" {
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

variable "master_ip_address" {
  type = "string"
}

variable "master_azure_fqdn" {
  type = "string"
}

variable "console_ip_address" {
  type = "string"
}

variable "console_azure_fqdn" {
  type = "string"
}

variable "use_custom_fqdn" {
  default = true
}

variable "external_dns_zone" { }

variable "public_ip_type" {
  type = "string"
}
