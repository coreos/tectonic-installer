variable "base_domain" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "cl_channel" {
  type = "string"
}

variable "dns_zone" {
  type = "string"
}

variable "az_count" {
  type = "string"
}

variable "instance_count" {
  default = "3"
}

variable "vpc_id" {
  type = "string"
}

variable "ssh_key" {
  type = "string"
}

variable "subnets" {
  type = "list"
}

variable "external_endpoints" {
  type = "list"
}

variable "container_image" {
  type = "string"
}

variable "ec2_type" {
  type = "string"
}
