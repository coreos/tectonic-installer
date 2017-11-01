data "ignition_config" "main" {
  files = [
    "${data.ignition_file.kubeconfig.id}",
    "${var.ign_max_user_watches_id}",
    "${var.ign_installer_kubelet_env_id}",
  ]

  systemd = [
    "${var.ign_docker_dropin_id}",
    "${var.ign_k8s_node_bootstrap_service_id}",
    "${var.ign_locksmithd_service_id}",
    "${var.ign_kubelet_service_id}",
  ]
}

data "ignition_file" "kubeconfig" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubeconfig"
  mode       = 0644

  content {
    content = "${var.kubeconfig_content}"
  }
}
