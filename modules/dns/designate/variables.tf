variable "cluster_name" {
  description = "The name of the cluster"
  type        = "string"
}

variable "base_domain" {
  description = "The base domain used in records"
  type        = "string"
}

variable "master_count" {
  description = "The number of masters"
  type        = "string"
}

variable "worker_count" {
  description = "The number of workers"
  type        = "string"
}

variable "etcd_count" {
  description = "The number of etcd nodes"
  type        = "string"
}

variable "etcd_ip_addresses" {
  description = "List of string IPs for etcd nodes"
  type        = "list"
}

variable "master_ip_addresses" {
  description = "List of string IPs for masters"
  type        = "list"
}

variable "worker_ip_addresses" {
  description = "List of string IPs for workers"
  type        = "list"
}

variable "worker_public_ips" {
  description = "(optional) List of string public IPs for workers"
  type        = "list"
  default     = []
}

// hack: worker_public_ips_enabled is a workaround for https://github.com/hashicorp/terraform/issues/10857
variable "worker_public_ips_enabled" {
  description = "Worker nodes have public IPs assigned. worker_public_ips must be provided if true."
  default     = true
}

variable "api_ip_addresses" {
  description = "List of string IPs for k8s API"
  type        = "list"
}
