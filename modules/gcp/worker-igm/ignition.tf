data "ignition_config" "main" {
  files = [
    "${var.ign_max_user_watches_id}",
    "${var.ign_gcs_puller_id}",
  ]

  systemd = [
    "${var.ign_docker_dropin_id}",
    "${var.ign_locksmithd_service_id}",
    "${var.ign_kubelet_service_id}",
    "${var.ign_gcs_kubelet_env_service_id}",
  ]
}
