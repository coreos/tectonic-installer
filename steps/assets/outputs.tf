output "ignition_etcd" {
  value = "${data.ignition_config.etcd.*.rendered}"
}
