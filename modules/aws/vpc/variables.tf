variable "cidr_block" {
  type = "string"
}

variable "cluster_id" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "external_vpc_id" {
  type = "string"
}

variable "external_master_subnet_ids" {
  type = "list"
}

variable "external_worker_subnet_ids" {
  type = "list"
}

variable "disable_s3_vpc_endpoint" {
  default = false
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}

variable "enable_etcd_sg" {
  description = "If set to true, security groups for etcd nodes are being created"
  default     = true
}

variable "new_master_subnet_configs" {
  type        = "map"
  description = "{az_name = new_subnet_cidr}: Empty map means create new subnets in all availability zones in region with generated cidrs"
}

variable "new_worker_subnet_configs" {
  type        = "map"
  description = "{az_name = new_subnet_cidr}: Empty map means create new subnets in all availability zones in region with generated cidrs."
}
