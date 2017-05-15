variable "arm_cloud" {
  type = "string"
}

variable "arm_client_secret" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "subnet_name" {
  type = "string"
}

variable "nsg_name" {
  type = "string"
}

variable "virtual_network" {
  type = "string"
}

variable "route_table_name" {
  type = "string"
  default = ""
}

variable "primary_availability_set_name" {
  type = "string"
}
