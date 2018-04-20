variable "ca_cert_pem" {
  type = "string"
}

variable "ca_key_pem" {
  type = "string"
}

variable "ca_key_alg" {
  type = "string"
}

variable "cert_chain" {
  description = <<EOF
  PEM-encoded certificatte chain that will be added to generated certs.
  Use this if you use a intermediate CA with multiple certificates in the chain.
EOF

  type        = "string"
}

variable "validity_period" {
  description = <<EOF
Validity period of the self-signed certificates (in hours).
Default is 3 years.
EOF

  type = "string"
}
