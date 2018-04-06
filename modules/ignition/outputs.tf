output "etcd_crt_id_list" {
  value = [
    "${data.ignition_file.etcd_ca.*.id}",
    "${data.ignition_file.etcd_client_key.*.id}",
    "${data.ignition_file.etcd_client_crt.*.id}",
    "${data.ignition_file.etcd_server_key.*.id}",
    "${data.ignition_file.etcd_server_crt.*.id}",
    "${data.ignition_file.etcd_peer_key.*.id}",
    "${data.ignition_file.etcd_peer_crt.*.id}",
  ]
}
