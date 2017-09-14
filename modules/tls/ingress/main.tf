module "ingress_certs_self_signed" {
  source = "./self-signed"

  base_address = "${var.base_address}"
  ca_cert_pem  = "${var.ca_cert_pem}"
  ca_key_pem   = "${var.ca_key_pem}"
  ca_key_alg   = "${var.ca_key_alg}"
}

module "ingress_certs_user_provided" {
  source = "./user-provided"

  ca_cert_pem = "${var.ingress_ca_cert_pem}"
  cert_pem    = "${var.ingress_cert_pem}"
  key_pem     = "${var.ingress_key_pem}"
}
