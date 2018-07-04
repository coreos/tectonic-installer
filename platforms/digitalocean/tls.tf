module "kube_certs" {
  source = "../../modules/tls/kube/self-signed"

  ca_cert_pem        = "${var.tectonic_ca_cert}"
  ca_key_alg         = "${var.tectonic_ca_key_alg}"
  ca_key_pem         = "${var.tectonic_ca_key}"
  cert_chain         = "${var.tectonic_cert_chain}"
  kube_apiserver_url = "https://${module.masters.cluster_fqdn}:443"
  service_cidr       = "${var.tectonic_service_cidr}"
  validity_period    = "${var.tectonic_tls_validity_period}"
}

module "etcd_certs" {
  source = "../../modules/tls/etcd/signed"

  etcd_ca_cert_path     = "${var.tectonic_etcd_ca_cert_path}"
  etcd_cert_dns_names   = "${data.template_file.etcd_hostname_list.*.rendered}"
  etcd_client_cert_path = "${var.tectonic_etcd_client_cert_path}"
  etcd_client_key_path  = "${var.tectonic_etcd_client_key_path}"
  self_signed           = "${var.tectonic_self_hosted_etcd != "" ? "true" : length(compact(var.tectonic_etcd_servers)) == 0 ? "true" : "false"}"
  service_cidr          = "${var.tectonic_service_cidr}"
}

module "ingress_certs" {
  source = "../../modules/tls/ingress/self-signed"

  base_address    = "${module.masters.console_fqdn}"
  ca_cert_pem     = "${module.kube_certs.ca_cert_pem}"
  ca_key_alg      = "${module.kube_certs.ca_key_alg}"
  ca_key_pem      = "${module.kube_certs.ca_key_pem}"
  cert_chain      = "${module.kube_certs.cert_chain}"
  validity_period = "${var.tectonic_tls_validity_period}"
}

module "identity_certs" {
  source = "../../modules/tls/identity/self-signed"

  ca_cert_pem     = "${module.kube_certs.ca_cert_pem}"
  ca_key_alg      = "${module.kube_certs.ca_key_alg}"
  ca_key_pem      = "${module.kube_certs.ca_key_pem}"
  cert_chain      = "${module.kube_certs.cert_chain}"
  validity_period = "${var.tectonic_tls_validity_period}"
}