data "terraform_remote_state" "bootstrap-assets" {
  backend = "local"

  config {
    path = "${path.module}/../../${var.tectonic_cluster_name}/assets.tfstate"
  }
}

locals {
  tectonic_bucket           = "${data.terraform_remote_state.bootstrap-assets.tectonic_bucket}"
  tectonic_key              = "${data.terraform_remote_state.bootstrap-assets.tectonic_key}"
  etcd_ca_crt_pem           = "${data.terraform_remote_state.bootstrap-assets.etcd_ca_crt_pem}"
  etcd_client_crt_pem       = "${data.terraform_remote_state.bootstrap-assets.etcd_client_crt_pem}"
  etcd_client_key_pem       = "${data.terraform_remote_state.bootstrap-assets.etcd_client_key_pem}"
  etcd_peer_crt_pem         = "${data.terraform_remote_state.bootstrap-assets.etcd_peer_crt_pem}"
  etcd_peer_key_pem         = "${data.terraform_remote_state.bootstrap-assets.etcd_peer_key_pem}"
  etcd_server_crt_pem       = "${data.terraform_remote_state.bootstrap-assets.etcd_server_crt_pem}"
  etcd_server_key_pem       = "${data.terraform_remote_state.bootstrap-assets.etcd_server_key_pem}"
  ingress_certs_ca_cert_pem = "${data.terraform_remote_state.bootstrap-assets.ingress_certs_ca_cert_pem}"
  kube_certs_ca_cert_pem    = "${data.terraform_remote_state.bootstrap-assets.kube_certs_ca_cert_pem}"
  kube_dns_service_ip       = "${data.terraform_remote_state.bootstrap-assets.kube_dns_service_ip}"
  s3_bucket                 = "${data.terraform_remote_state.bootstrap-assets.s3_bucket}"
  cluster_id                = "${data.terraform_remote_state.bootstrap-assets.cluster_id}"
  bootkube_service          = "${data.terraform_remote_state.bootstrap-assets.bootkube_service}"
}
