output "etcd_crt_id_list" {
  value = "${module.ignition_masters.etcd_crt_id_list}"
}

output "etcd_dropin_id_list" {
  value = "${module.ignition_masters.etcd_dropin_id_list}"
}
