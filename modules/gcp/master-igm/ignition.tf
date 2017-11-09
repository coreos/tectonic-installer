data "ignition_config" "main" {
  files = [
    "${data.ignition_file.kubeconfig.id}",
    "${var.ign_max_user_watches_id}",
    "${var.ign_installer_kubelet_env_id}",
  ]

  systemd = ["${compact(list(
    var.ign_docker_dropin_id,
    var.ign_locksmithd_service_id,
    var.ign_kubelet_service_id,
    var.ign_k8s_node_bootstrap_service_id,
    var.ign_bootkube_service_id,
    var.ign_tectonic_service_id,
    var.ign_bootkube_path_unit_id,
    var.ign_tectonic_path_unit_id,
    data.ignition_systemd_unit.move_assets.id
   ))}"]
}

data "ignition_file" "kubeconfig" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubeconfig"
  mode       = 0644

  content {
    content = "${var.kubeconfig_content}"
  }
}

data "template_file" "move_assets" {
  template = "${file("${path.module}/resources/services/move-assets.service")}"
}

data "ignition_systemd_unit" "move_assets" {
  name    = "move-assets.service"
  enable  = true
  content = "${data.template_file.move_assets.rendered}"
}
