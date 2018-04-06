variable "etcd_ca_cert_pem" {
  type        = "string"
  description = "The etcd kube CA certificate in PEM format."
}

variable "etcd_client_key_pem" {
  default = ""
}

variable "etcd_client_crt_pem" {
  default = ""
}

variable "etcd_server_key_pem" {
  default = ""
}

variable "etcd_server_crt_pem" {
  default = ""
}

variable "etcd_peer_key_pem" {
  default = ""
}

variable "etcd_peer_crt_pem" {
  default = ""
}

variable "etcd_count" {
  type    = "string"
  default = 0
}
