variable "container_images" {
  type = "map"
}

variable "ssh_key" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "cl_channel" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "ec2_type" {
  type = "string"
}

variable "instance_count" {
  type = "string"
}

variable "etcd_endpoints" {
  type = "list"
}

variable "subnet_ids" {
  type = "list"
}

variable "extra_sg_ids" {
  type = "list"
}

variable "kubeconfig_content" {
  type = "string"
}

variable "kube_dns_service_ip" {
  type = "string"
}
