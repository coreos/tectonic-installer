###############################################################################
#                        Provider Configuration Values                        #
###############################################################################
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

###############################################################################
#                            Host VM Configuration                            #
###############################################################################

variable "public_ssh_key" {
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
