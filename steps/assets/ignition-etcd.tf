// TODO(alberto): move this into TNC Etcd TLS bootstrap
// https://github.com/coreos-inc/tectonic-operators/pull/295
locals {
  etcd_internal_instance_count = "${length(data.template_file.etcd_hostname_list.*.id)}"
  etcd_instance_count          = "${length(compact(var.tectonic_etcd_servers)) == 0 ? local.etcd_internal_instance_count : 0}"
}

module "ignition_etcd_tls" {
  source              = "../../modules/ignition"
  etcd_ca_cert_pem    = "${module.ca_certs.etcd_ca_cert_pem}"
  etcd_client_crt_pem = "${module.etcd_certs.etcd_client_cert_pem}"
  etcd_client_key_pem = "${module.etcd_certs.etcd_client_key_pem}"
  etcd_count          = "${length(data.template_file.etcd_hostname_list.*.id)}"
  etcd_peer_crt_pem   = "${module.etcd_certs.etcd_peer_cert_pem}"
  etcd_peer_key_pem   = "${module.etcd_certs.etcd_peer_key_pem}"
  etcd_server_crt_pem = "${module.etcd_certs.etcd_server_cert_pem}"
  etcd_server_key_pem = "${module.etcd_certs.etcd_server_key_pem}"
}

data "ignition_config" "etcd" {
  count = "${local.etcd_instance_count}"

  files = ["${module.ignition_etcd_tls.etcd_crt_id_list}"]
}
