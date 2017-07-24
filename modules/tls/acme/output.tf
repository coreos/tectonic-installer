output "account_key_pem" {
  value = "${tls_private_key.account.private_key_pem}"
}

output "private_key_pem" {
  value = "${tls_private_key.ingress.private_key_pem}"
}

output "cert_pem" {
  value = "${acme_certificate.ingress.certificate_pem}"
}

output "ca_cert_pem" {
  value = "${acme_certificate.ingress.issuer_pem}"
}
