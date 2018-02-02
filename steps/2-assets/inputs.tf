data "terraform_remote_state" "tls" {
  backend = "local"

  config {
    path = "${path.module}/../../${var.tectonic_cluster_name}/tls.tfstate"
  }
}

locals {
  etcd_ca_crt_pem                = "${data.terraform_remote_state.tls.etcd_ca_crt_pem}"
  etcd_client_crt_pem            = "${data.terraform_remote_state.tls.etcd_client_crt_pem}"
  etcd_client_key_pem            = "${data.terraform_remote_state.tls.etcd_client_key_pem}"
  etcd_peer_crt_pem              = "${data.terraform_remote_state.tls.etcd_peer_crt_pem}"
  etcd_peer_key_pem              = "${data.terraform_remote_state.tls.etcd_peer_key_pem}"
  etcd_server_crt_pem            = "${data.terraform_remote_state.tls.etcd_server_crt_pem}"
  etcd_server_key_pem            = "${data.terraform_remote_state.tls.etcd_server_key_pem}"
  ingress_certs_ca_cert_pem      = "${data.terraform_remote_state.tls.ingress_certs_ca_cert_pem}"
  ingress_certs_cert_pem         = "${data.terraform_remote_state.tls.ingress_certs_cert_pem}"
  ingress_certs_key_pem          = "${data.terraform_remote_state.tls.ingress_certs_key_pem}"
  kube_certs_ca_cert_pem         = "${data.terraform_remote_state.tls.kube_certs_ca_cert_pem}"
  kube_certs_apiserver_cert_pem  = "${data.terraform_remote_state.tls.kube_certs_apiserver_cert_pem}"
  kube_certs_apiserver_key_pem   = "${data.terraform_remote_state.tls.kube_certs_apiserver_key_pem}"
  kube_certs_kubelet_cert_pem    = "${data.terraform_remote_state.tls.kube_certs_kubelet_cert_pem}"
  kube_certs_kubelet_key_pem     = "${data.terraform_remote_state.tls.kube_certs_kubelet_key_pem}"
  identity_certs_client_cert_pem = "${data.terraform_remote_state.tls.identity_certs_client_cert_pem}"
  identity_certs_client_key_pem  = "${data.terraform_remote_state.tls.identity_certs_client_key_pem}"
  identity_certs_server_cert_pem = "${data.terraform_remote_state.tls.identity_certs_server_cert_pem}"
  identity_certs_server_key_pem  = "${data.terraform_remote_state.tls.identity_certs_server_key_pem}"
}
