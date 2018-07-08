locals {
  server_crt_chain = "${tls_locally_signed_cert.identity_server.cert_pem}${var.cert_chain}"
}

output "client_key_pem" {
  value = "${tls_private_key.identity_client.private_key_pem}"
}

output "client_cert_pem" {
  value = "${tls_locally_signed_cert.identity_client.cert_pem}"
}

output "server_key_pem" {
  value = "${tls_private_key.identity_server.private_key_pem}"
}

output "server_cert_pem" {
  value = "${var.cert_chain == "" ? tls_locally_signed_cert.identity_server.cert_pem : local.server_crt_chain}"
}
