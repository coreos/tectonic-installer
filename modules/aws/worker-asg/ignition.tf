data "ignition_config" "main" {
  files = [
    "${var.ign_installer_kubelet_env_id}",
    "${var.ign_installer_runtime_mappings_id}",
    "${var.ign_max_user_watches_id}",
    "${var.ign_s3_puller_id}",
    "${data.ignition_file.ca_cert_pem.*.id}",
  ]

  systemd = [
    "${var.ign_docker_dropin_id}",
    "${var.ign_k8s_node_bootstrap_service_id}",
    "${var.ign_kubelet_service_id}",
    "${var.ign_locksmithd_service_id}",
    "${var.ign_update_ca_certificates_dropin_id}",
  ]
}

data "ignition_file" "ca_cert_pem" {
  count = "${var.ign_ca_cert_list_count}"

  filesystem = "root"
  path       = "/etc/ssl/certs/ca_${count.index}.pem"
  mode       = 0400
  uid        = 0
  gid        = 0

  source {
    source       = "${var.ign_ca_cert_s3_list[count.index]}"
    verification = "sha512-${sha512(var.ign_ca_cert_pem_list[count.index])}"
  }
}
