output "ca_cert_pem" {
  value = "${var.ingress_ca_cert_pem == "" ? module.ingress_certs_self_signed.ca_cert_pem : module.ingress_certs_user_provided.ca_cert_pem}"
}

output "cert_pem" {
  value = "${var.ingress_ca_cert_pem == "" ? module.ingress_certs_self_signed.cert_pem : module.ingress_certs_user_provided.cert_pem}"
}

output "key_pem" {
  value = "${var.ingress_ca_cert_pem == "" ? module.ingress_certs_self_signed.key_pem : module.ingress_certs_user_provided.key_pem}"
}
