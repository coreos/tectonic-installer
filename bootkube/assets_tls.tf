# Kubernetes CA
resource "tls_private_key" "kube-ca" {
  algorithm = "ECDSA"
}

resource "tls_self_signed_cert" "kube-ca" {
  key_algorithm = "${tls_private_key.kube-ca.algorithm}"
  private_key_pem = "${tls_private_key.kube-ca.private_key_pem}"

  subject {
    common_name = "kube-ca"
    organization = "bootkube"
  }

  is_ca_certificate = true
  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

# Kubernetes API Server
resource "tls_private_key" "apiserver" {
  algorithm = "ECDSA"
}

resource "tls_cert_request" "apiserver" {
  key_algorithm = "${tls_private_key.apiserver.algorithm}"
  private_key_pem = "${tls_private_key.apiserver.private_key_pem}"

  subject {
    common_name = "kube-apiserver"
    organization = "kube-master"
  }

  dns_names = [
    "${var.kube_apiserver_service_ip}",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local",
  ]
}

resource "tls_locally_signed_cert" "apiserver" {
  cert_request_pem = "${tls_cert_request.apiserver.cert_request_pem}"

  ca_key_algorithm = "${tls_self_signed_cert.kube-ca.key_algorithm}"
  ca_private_key_pem = "${tls_private_key.kube-ca.private_key_pem}"
  ca_cert_pem = "${tls_self_signed_cert.kube-ca.cert_pem}"

  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

# Kubernete's Service Account
resource "tls_private_key" "service-account" {
  algorithm = "ECDSA"
}

# Kubelet
resource "tls_private_key" "kubelet" {
  algorithm = "ECDSA"
}

resource "tls_cert_request" "kubelet" {
  key_algorithm = "${tls_private_key.kubelet.algorithm}"
  private_key_pem = "${tls_private_key.kubelet.private_key_pem}"

  subject {
    common_name = "kubelet"
    organization = "system:masters"
  }
}

resource "tls_locally_signed_cert" "kubelet" {
  cert_request_pem = "${tls_cert_request.kubelet.cert_request_pem}"

  ca_key_algorithm = "${tls_self_signed_cert.kube-ca.key_algorithm}"
  ca_private_key_pem = "${tls_private_key.kube-ca.private_key_pem}"
  ca_cert_pem = "${tls_self_signed_cert.kube-ca.cert_pem}"

  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}