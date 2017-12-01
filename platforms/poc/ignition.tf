data "ignition_config" "bootstrap" {
  files = [
    "${module.ignition_bootstrap.installer_kubelet_env_id}",
    "${module.ignition_bootstrap.installer_runtime_mappings_id}",
    "${module.ignition_bootstrap.ca_cert_id_list}",
    "${data.ignition_file.kubeconfig.id}",
    "${data.ignition_file.bootstrap_hostname.id}",
  ]

  systemd = [
    "${module.bootkube.systemd_path_unit_id}",
    "${module.bootkube.systemd_service_id}",
    "${module.tectonic.systemd_path_unit_id}",
    "${module.tectonic.systemd_service_id}",
    "${module.ignition_bootstrap.docker_dropin_id}",
    "${module.ignition_bootstrap.k8s_node_bootstrap_service_id}",
    "${module.ignition_bootstrap.kubelet_service_id}",
    "${module.ignition_bootstrap.locksmithd_service_id}",
  ]

  users = [
    "${data.ignition_user.core.id}",
  ]
}

data "ignition_config" "worker" {
  count = "${length(var.tectonic_metal_worker_names)}"

  files = [
    "${module.ignition_workers.installer_kubelet_env_id}",
    "${module.ignition_workers.installer_runtime_mappings_id}",
    "${data.ignition_file.kubeconfig.id}",
    "${data.ignition_file.worker_hostname.*.id[count.index]}",
  ]

  systemd = [
    "${module.ignition_workers.docker_dropin_id}",
    "${module.ignition_workers.kubelet_service_id}",
    "${module.ignition_bootstrap.locksmithd_service_id}",
    "${module.ignition_workers.k8s_node_bootstrap_service_id}",
  ]

  users = [
    "${data.ignition_user.core.id}",
  ]
}

data "ignition_config" "master" {
  count = "${length(var.tectonic_metal_controller_names)}"

  files = [
    "${module.ignition_masters.installer_kubelet_env_id}",
    "${module.ignition_masters.installer_runtime_mappings_id}",
    "${data.ignition_file.kubeconfig.id}",
    "${module.ignition_masters.etcd_crt_id_list}",
    "${data.ignition_file.master_hostname.*.id[count.index]}",
  ]

  systemd = [
    "${module.ignition_masters.docker_dropin_id}",
    "${module.ignition_masters.k8s_node_bootstrap_service_id}",
    "${module.ignition_masters.kubelet_service_id}",
    "${module.ignition_bootstrap.locksmithd_service_id}",
    "${module.ignition_masters.etcd_dropin_id_list[count.index]}",
  ]

  users = [
    "${data.ignition_user.core.id}",
  ]
}

data "ignition_file" "kubeconfig" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubeconfig"
  mode       = 0644

  content {
    content = "${module.bootkube.kubeconfig}"
  }
}

data "ignition_file" "bootstrap_hostname" {
  path       = "/etc/hostname"
  mode       = 0644
  filesystem = "root"

  content {
    content = "bootstrap.k8s"
  }
}

data "ignition_file" "master_hostname" {
  count      = "${length(var.tectonic_metal_controller_names)}"
  path       = "/etc/hostname"
  mode       = 0644
  filesystem = "root"

  content {
    content = "${element(var.tectonic_metal_controller_domains, count.index)}"
  }
}

data "ignition_file" "worker_hostname" {
  count      = "${length(var.tectonic_metal_worker_names)}"
  path       = "/etc/hostname"
  mode       = 0644
  filesystem = "root"

  content {
    content = "${element(var.tectonic_metal_worker_domains, count.index)}"
  }
}

data "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = ["${var.tectonic_ssh_authorized_key}"]
}

module "ignition_bootstrap" {
  source = "../../modules/ignition"

  bootstrap_upgrade_cl      = "${var.tectonic_bootstrap_upgrade_cl}"
  cluster_name              = "${var.tectonic_cluster_name}"
  container_images          = "${var.tectonic_container_images}"
  custom_ca_cert_pem_list   = "${var.tectonic_custom_ca_pem_list}"
  etcd_advertise_name_list  = "${var.tectonic_metal_controller_domains}"
  etcd_ca_cert_pem          = "${module.etcd_certs.etcd_ca_crt_pem}"
  etcd_count                = "${length(var.tectonic_metal_controller_names)}"
  etcd_initial_cluster_list = "${var.tectonic_metal_controller_domains}"
  image_re                  = "${var.tectonic_image_re}"
  ingress_ca_cert_pem       = "${module.ingress_certs.ca_cert_pem}"
  kube_ca_cert_pem          = "${module.kube_certs.ca_cert_pem}"
  kube_dns_service_ip       = "${module.bootkube.kube_dns_service_ip}"
  kubelet_cni_bin_dir       = "${var.tectonic_networking == "calico" || var.tectonic_networking == "canal" ? "/var/lib/cni/bin" : "" }"
  kubelet_debug_config      = "${var.tectonic_kubelet_debug_config}"
  kubelet_node_label        = "node-role.kubernetes.io/bootstrap"
  kubelet_node_taints       = "node-role.kubernetes.io/bootstrap=:NoSchedule"
  tectonic_vanilla_k8s      = "${var.tectonic_vanilla_k8s}"
  use_metadata              = false
}

module "ignition_masters" {
  source = "../../modules/ignition"

  bootstrap_upgrade_cl      = "${var.tectonic_bootstrap_upgrade_cl}"
  cluster_name              = "${var.tectonic_cluster_name}"
  container_images          = "${var.tectonic_container_images}"
  custom_ca_cert_pem_list   = "${var.tectonic_custom_ca_pem_list}"
  etcd_advertise_name_list  = "${var.tectonic_metal_controller_domains}"
  etcd_ca_cert_pem          = "${module.etcd_certs.etcd_ca_crt_pem}"
  etcd_client_crt_pem       = "${module.etcd_certs.etcd_client_crt_pem}"
  etcd_client_key_pem       = "${module.etcd_certs.etcd_client_key_pem}"
  etcd_count                = "${length(var.tectonic_metal_controller_names)}"
  etcd_initial_cluster_list = "${var.tectonic_metal_controller_domains}"
  etcd_peer_crt_pem         = "${module.etcd_certs.etcd_peer_crt_pem}"
  etcd_peer_key_pem         = "${module.etcd_certs.etcd_peer_key_pem}"
  etcd_server_crt_pem       = "${module.etcd_certs.etcd_server_crt_pem}"
  etcd_server_key_pem       = "${module.etcd_certs.etcd_server_key_pem}"
  etcd_tls_enabled          = "${var.tectonic_etcd_tls_enabled}"
  image_re                  = "${var.tectonic_image_re}"
  ingress_ca_cert_pem       = "${module.ingress_certs.ca_cert_pem}"
  kube_ca_cert_pem          = "${module.kube_certs.ca_cert_pem}"
  kube_dns_service_ip       = "${module.bootkube.kube_dns_service_ip}"
  kubelet_cni_bin_dir       = "${var.tectonic_networking == "calico" || var.tectonic_networking == "canal" ? "/var/lib/cni/bin" : "" }"
  kubelet_debug_config      = "${var.tectonic_kubelet_debug_config}"
  kubelet_node_label        = "node-role.kubernetes.io/master"
  kubelet_node_taints       = "node-role.kubernetes.io/master=:NoSchedule"
  tectonic_vanilla_k8s      = "${var.tectonic_vanilla_k8s}"
  use_metadata              = false
}

module "ignition_workers" {
  source = "../../modules/ignition"

  bootstrap_upgrade_cl    = "${var.tectonic_bootstrap_upgrade_cl}"
  container_images        = "${var.tectonic_container_images}"
  custom_ca_cert_pem_list = "${var.tectonic_custom_ca_pem_list}"
  etcd_ca_cert_pem        = "${module.etcd_certs.etcd_ca_crt_pem}"
  image_re                = "${var.tectonic_image_re}"
  ingress_ca_cert_pem     = "${module.ingress_certs.ca_cert_pem}"
  kube_ca_cert_pem        = "${module.kube_certs.ca_cert_pem}"
  kube_dns_service_ip     = "${module.bootkube.kube_dns_service_ip}"
  kubelet_cni_bin_dir     = "${var.tectonic_networking == "calico" || var.tectonic_networking == "canal" ? "/var/lib/cni/bin" : "" }"
  kubelet_debug_config    = "${var.tectonic_kubelet_debug_config}"
  kubelet_node_label      = "node-role.kubernetes.io/node"
  kubelet_node_taints     = ""
  tectonic_vanilla_k8s    = "${var.tectonic_vanilla_k8s}"
}
