/*
This is the ignition config for the NCG.
It's currently made available for the NCG as configMap volume.
It is in the assets step to be dropped in the generated folder so the configMap gets deployed
This needs to get consolidated with the NCG ignition chain workflow
TODO: Move ignition generation out of terraform
*/

module "ignition_workers" {
  source = "../../modules/ignition"

  bootstrap_upgrade_cl    = "${var.tectonic_bootstrap_upgrade_cl}"
  cloud_provider          = "aws"
  container_images        = "${var.tectonic_container_images}"
  custom_ca_cert_pem_list = "${var.tectonic_custom_ca_pem_list}"
  etcd_ca_cert_pem        = "${module.etcd_certs.etcd_ca_crt_pem}"
  http_proxy              = "${var.tectonic_http_proxy_address}"
  https_proxy             = "${var.tectonic_https_proxy_address}"
  image_re                = "${var.tectonic_image_re}"
  ingress_ca_cert_pem     = "${module.ingress_certs.ca_cert_pem}"
  iscsi_enabled           = "${var.tectonic_iscsi_enabled}"
  kube_ca_cert_pem        = "${module.kube_certs.ca_cert_pem}"
  kube_dns_service_ip     = "${module.bootkube.kube_dns_service_ip}"
  kubelet_debug_config    = "${var.tectonic_kubelet_debug_config}"
  kubelet_node_label      = "node-role.kubernetes.io/node"
  kubelet_node_taints     = ""
  no_proxy                = "${var.tectonic_no_proxy}"
}

data "ignition_config" "workers" {
  files = ["${compact(list(
    module.ignition_workers.installer_kubelet_env_id,
    module.ignition_workers.installer_runtime_mappings_id,
    module.ignition_workers.max_user_watches_id,
    module.ignition_workers.s3_puller_id,
    module.ignition_workers.profile_env_id,
    module.ignition_workers.systemd_default_env_id,
   ))}",
    "${module.ignition_workers.ca_cert_id_list}",
  ]

  systemd = [
    "${module.ignition_workers.docker_dropin_id}",
    "${module.ignition_workers.k8s_node_bootstrap_service_id}",
    "${module.ignition_workers.kubelet_service_id}",
    "${module.ignition_workers.locksmithd_service_id}",
    "${module.ignition_workers.update_ca_certificates_dropin_id}",
    "${module.ignition_workers.iscsi_service_id}",
  ]
}
