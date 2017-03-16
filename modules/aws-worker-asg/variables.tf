variable "ssh_key" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "tectonic_cl_channel" {
  type = "string"
}

variable "tectonic_base_domain" {
  type = "string"
}

variable "tectonic_cluster_name" {
  type = "string"
}

variable "tectonic_aws_worker_ec2_type" {
  type = "string"
}

variable "tectonic_worker_count" {
  type = "string"
}

variable "tectonic_kube_version" {
  type = "string"
}

variable "etcd_endpoints" {
  type = "list"
}

variable "worker_subnet_ids" {
  type = "list"
}

variable "extra_sg_ids" {
  type = "list"
}
