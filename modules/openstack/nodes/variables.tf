variable "bootkube_service" {
  type = "string"
}

variable "cluster_name" {
  type        = "string"
  description = "The name of the cluster. The master hostnames will be prefixed with this."
}

variable "core_public_keys" {
  type = "list"
}

variable "hostname_infix" {
  type = "string"
}

variable "instance_count" {
  type        = "string"
  description = "The amount of nodes to be created. Example: `3`"
}

variable "tectonic_service" {
  type = "string"
}

variable "tectonic_service_disabled" {
  description = "Specifies whether the tectonic installer systemd unit will be disabled. If true, no tectonic assets will be deployed"
  default     = false
}

variable kube_image_tag {
  type        = "string"
  description = "The hyperkube image tag."
}

variable kube_image_url {
  type        = "string"
  description = "The hyperkube image url."
}

variable kubeconfig_content {
  type        = "string"
  description = "The content of the kubeconfig file."
}

variable resolv_conf_content {
  type        = "string"
  description = "The content of the /etc/resolv.conf file."
}
