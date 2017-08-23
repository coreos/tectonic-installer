variable "bootkube_service" {
  type        = "string"
  description = "The content of the bootkube systemd service unit"
}

variable "cl_channel" {
  type = "string"
}

variable "cloud_provider_config" {
  type = "string"
}

variable "cluster_id" {
  type = "string"
}

variable "cluster_name" {
  type        = "string"
  description = "The name of the cluster."
}

variable "extra_tags" {
  type = "map"
}

variable "kube_image_tag" {
  type = "string"
}

variable "kube_image_url" {
  type = "string"
}

variable "kubeconfig_content" {
  type = "string"
}

variable "location" {
  type        = "string"
  description = "Location is the Azure Location (East US, West US, etc)"
}

variable "master_count" {
  type        = "string"
  description = "Count of master nodes to be created."
}

variable "network_interface_ids" {
  type        = "list"
  description = "List of NICs to use for master VMs"
}

variable "public_ssh_key" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "storage_id" {
  type = "string"
}

variable "storage_type" {
  type        = "string"
  description = "Storage account type"
}

variable "tectonic_service" {
  type        = "string"
  description = "The content of the tectonic installer systemd service unit"
}

variable "tectonic_service_disabled" {
  description = "Specifies whether the tectonic installer systemd unit will be disabled. If true, no tectonic assets will be deployed"
  default     = false
}

variable "vm_size" {
  type        = "string"
  description = "VM Size name"
}
