variable "ca_cert_pem_path" {
  type = "string"
}

variable "kubelet_cert_pem_path" {
  type = "string"
}

variable "kubelet_key_pem_path" {
  type = "string"
}

variable "apiserver_cert_pem_path" {
  type = "string"
}

variable "apiserver_key_pem_path" {
  type = "string"
}

variable "all_ca_list" {
  type = "list"
  default = [
    "local_file.apiserver_key.id",
    "local_file.apiserver_crt.id",
    "local_file.kube_ca_key.id",
    "local_file.kube_ca_crt.id",
    "local_file.kubelet_key.id",
    "local_file.kubelet_crt.id",
  ]
}
