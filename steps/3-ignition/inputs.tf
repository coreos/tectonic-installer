data "terraform_remote_state" "assets" {
  backend = "local"

  config {
    path = "${path.module}/../../${var.tectonic_cluster_name}/assets.tfstate"
  }
}

data "terraform_remote_state" "tls" {
  backend = "local"

  config {
    path = "${path.module}/../../${var.tectonic_cluster_name}/tls.tfstate"
  }
}

locals {
  etcd_ca_crt_pem           = "${data.terraform_remote_state.tls.etcd_ca_crt_pem}"
  etcd_client_crt_pem       = "${data.terraform_remote_state.tls.etcd_client_crt_pem}"
  etcd_client_key_pem       = "${data.terraform_remote_state.tls.etcd_client_key_pem}"
  etcd_peer_crt_pem         = "${data.terraform_remote_state.tls.etcd_peer_crt_pem}"
  etcd_peer_key_pem         = "${data.terraform_remote_state.tls.etcd_peer_key_pem}"
  etcd_server_crt_pem       = "${data.terraform_remote_state.tls.etcd_server_crt_pem}"
  etcd_server_key_pem       = "${data.terraform_remote_state.tls.etcd_server_key_pem}"
  ingress_certs_ca_cert_pem = "${data.terraform_remote_state.tls.ingress_certs_ca_cert_pem}"
  kube_certs_ca_cert_pem    = "${data.terraform_remote_state.tls.kube_certs_ca_cert_pem}"
  tectonic_bucket           = "${data.terraform_remote_state.assets.tectonic_bucket}"
  tectonic_key              = "${data.terraform_remote_state.assets.tectonic_key}"
  kube_dns_service_ip       = "${data.terraform_remote_state.assets.kube_dns_service_ip}"
  s3_bucket                 = "${data.terraform_remote_state.assets.s3_bucket}"
  cluster_id                = "${data.terraform_remote_state.assets.cluster_id}"
  bootkube_service          = "${data.terraform_remote_state.assets.bootkube_service}"
}
