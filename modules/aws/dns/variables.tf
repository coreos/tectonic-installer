variable "vpc_id" {
  type = "string"
}

variable "base_domain" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "console_elb" {
  type = "map"
}

variable "api_internal_elb" {
  type = "map"
}

variable "api_external_elb" {
  type = "map"
}
