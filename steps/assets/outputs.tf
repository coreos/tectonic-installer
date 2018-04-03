output "kubeconfig_kubelet_content" {
  value = "${module.bootkube.kubeconfig}" ## TODO(abhinav): TLS boostrapping using service account
}

output "ignition_bootstrap" {
  value = "${data.ignition_config.bootstrap.rendered}"
}

output "ignition_etcd" {
  value = "${data.ignition_config.etcd.*.rendered}"
}
