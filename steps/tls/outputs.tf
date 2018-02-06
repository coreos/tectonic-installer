output "etcd_ca_crt_pem" {
  value = "${module.etcd_certs.etcd_ca_crt_pem}"
}

output "etcd_client_crt_pem" {
  value = "${module.etcd_certs.etcd_client_crt_pem}"
}

output "etcd_client_key_pem" {
  value = "${module.etcd_certs.etcd_client_key_pem}"
}

output "etcd_peer_crt_pem" {
  value = "${module.etcd_certs.etcd_peer_crt_pem}"
}

output "etcd_peer_key_pem" {
  value = "${module.etcd_certs.etcd_peer_key_pem}"
}

output "etcd_server_crt_pem" {
  value = "${module.etcd_certs.etcd_server_crt_pem}"
}

output "etcd_server_key_pem" {
  value = "${module.etcd_certs.etcd_server_key_pem}"
}

output "ingress_certs_ca_cert_pem" {
  value = "${module.ingress_certs.ca_cert_pem}"
}

output "ingress_certs_cert_pem" {
  value = "${module.ingress_certs.cert_pem}"
}

output "ingress_certs_key_pem" {
  value = "${module.ingress_certs.key_pem}"
}

output "kube_certs_ca_cert_pem" {
  value = "${module.kube_certs.ca_cert_pem}"
}

output "kube_certs_kubelet_cert_pem" {
  value = "${module.kube_certs.kubelet_cert_pem}"
}

output "kube_certs_kubelet_key_pem" {
  value = "${module.kube_certs.kubelet_key_pem}"
}

output "kube_certs_apiserver_cert_pem" {
  value = "${module.kube_certs.apiserver_cert_pem}"
}

output "kube_certs_apiserver_key_pem" {
  value = "${module.kube_certs.apiserver_key_pem}"
}

output "identity_certs_client_cert_pem" {
  value = "${module.identity_certs.client_cert_pem}"
}

output "identity_certs_client_key_pem" {
  value = "${module.identity_certs.client_key_pem}"
}

output "identity_certs_server_cert_pem" {
  value = "${module.identity_certs.server_cert_pem}"
}

output "identity_certs_server_key_pem" {
  value = "${module.identity_certs.server_key_pem}"
}
