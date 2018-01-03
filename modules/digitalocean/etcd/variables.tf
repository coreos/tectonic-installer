variable "base_domain" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "droplet_count" {
  type = "string"
}

variable "droplet_size" {
  type = "string"
}

variable "extra_tags" {
  type    = "list"
  default = []
}

variable "ssh_keys" {
  type = "list"
}

variable "droplet_region" {
  type = "string"
}

variable "droplet_image" {
  type = "string"
}

variable "tls_enabled" {
  default = false
}

variable "ign_etcd_dropin_id_list" {
  type = "list"
}

variable "ign_etcd_crt_id_list" {
  type = "list"
}
