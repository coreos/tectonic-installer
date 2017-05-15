variable "public_ssh_key" {
  type = "string"
}

variable "cloud_config" {
  type = "string"
}

variable "kubeconfig_content" {
  type = "string"
}

variable "kube_dns_service_ip" {
  type = "string"
}

variable "kubelet_node_label" {
  type = "string"
}

variable "kubelet_node_taints" {
  type = "string"
}

variable "kube_image_url" {
  type = "string"
}

variable "kube_image_tag" {
  type = "string"
}

variable "bootkube_service" {
  type        = "string"
  description = "The content of the bootkube systemd service unit"
}

variable "tectonic_service" {
  type        = "string"
  description = "The content of the tectonic installer systemd service unit"
}

variable "tectonic_service_disabled" {
  description = "Specifies whether the tectonic installer systemd unit will be disabled. If true, no tectonic assets will be deployed"
  default     = false
}
