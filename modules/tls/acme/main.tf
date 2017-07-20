resource "tls_private_key" "account" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_private_key" "ingress" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "ingress" {
  key_algorithm   = "${tls_private_key.ingress.algorithm}"
  private_key_pem = "${tls_private_key.ingress.private_key_pem}"

  subject {
    common_name = "${element(split(":", var.base_address), 0)}"
  }

  # subject commonName is deprecated per RFC2818 in favor of
  # subjectAltName
  dns_names = [
    "${element(split(":", var.base_address), 0)}",
  ]
}

resource "acme_registration" "ingress" {
  server_url      = "${var.server_url}"
  account_key_pem = "${tls_private_key.account.private_key_pem}"
  email_address   = "${var.email_address}"
}

resource "acme_certificate" "ingress" {
  server_url              = "${var.server_url}"
  account_key_pem         = "${tls_private_key.account.private_key_pem}"
  certificate_request_pem = "${tls_cert_request.ingress.cert_request_pem}"

  dns_challenge {
    provider = "${var.provider}"
    config   = "${var.provider_config}"
  }

  registration_url = "${acme_registration.ingress.id}"
}
