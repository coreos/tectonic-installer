/*
Copyright 2017 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

provider "google" {
  region  = "${var.tectonic_gcp_region}"
  version = "1.1.0"
}

module "container_linux" {
  source = "../../modules/container_linux"

  channel = "${var.tectonic_container_linux_channel}"
  version = "${var.tectonic_container_linux_version}"
}

module "network" {
  source = "../../modules/gcp/network"

  gcp_region           = "${var.tectonic_gcp_region}"
  master_ip_cidr_range = "10.10.0.0/16"
  worker_ip_cidr_range = "10.11.0.0/16"

  managed_zone_name = "${var.tectonic_gcp_ext_google_managedzone_name}"
  base_domain       = "${var.tectonic_base_domain}"
  cluster_name      = "${var.tectonic_cluster_name}"

  master_instance_group = "${module.masters.instance_group}"
}

data "google_compute_zones" "available" {}

module "etcd" {
  source            = "../../modules/gcp/etcd"
  instance_count    = "${var.tectonic_self_hosted_etcd != "" ? 0 : var.tectonic_etcd_count > 0 ? var.tectonic_etcd_count : length(data.google_compute_zones.available.names) == 5 ? 5 : 3}"
  zone_list         = "${data.google_compute_zones.available.names}"
  machine_type      = "${var.tectonic_gcp_etcd_gce_type}"
  managed_zone_name = "${var.tectonic_gcp_ext_google_managedzone_name}"
  cluster_name      = "${var.tectonic_cluster_name}"
  public_ssh_key    = "${var.tectonic_gcp_ssh_key}"
  base_domain       = "${var.tectonic_base_domain}"
  container_image   = "${var.tectonic_container_images["etcd"]}"

  cl_channel = "${var.tectonic_container_linux_channel}"

  disk_type = "${var.tectonic_gcp_etcd_disktype}"
  disk_size = "${var.tectonic_gcp_etcd_disk_size}"

  master_subnetwork_name = "${module.network.master_subnetwork_name}"
  external_endpoints     = ["${compact(var.tectonic_etcd_servers)}"]

  tls_enabled             = "${var.tectonic_etcd_tls_enabled}"
  tls_ca_crt_pem          = "${module.etcd_certs.etcd_ca_crt_pem}"
  tls_server_crt_pem      = "${module.etcd_certs.etcd_server_crt_pem}"
  tls_server_key_pem      = "${module.etcd_certs.etcd_server_key_pem}"
  tls_client_crt_pem      = "${module.etcd_certs.etcd_client_crt_pem}"
  tls_client_key_pem      = "${module.etcd_certs.etcd_client_key_pem}"
  tls_peer_crt_pem        = "${module.etcd_certs.etcd_peer_crt_pem}"
  tls_peer_key_pem        = "${module.etcd_certs.etcd_peer_key_pem}"
  ign_etcd_dropin_id_list = "${module.ignition_masters.etcd_dropin_id_list}"
}

module "masters" {
  source = "../../modules/gcp/master-igm"

  region             = "${var.tectonic_gcp_region}"
  instance_count     = "${var.tectonic_master_count}"
  machine_type       = "${var.tectonic_gcp_master_gce_type}"
  cluster_name       = "${var.tectonic_cluster_name}"
  public_ssh_key     = "${var.tectonic_gcp_ssh_key}"
  kubeconfig_content = "${module.bootkube.kubeconfig}"

  master_subnetwork_name      = "${module.network.master_subnetwork_name}"
  master_targetpool_self_link = "${module.network.master_targetpool_self_link}"

  cl_channel = "${var.tectonic_container_linux_channel}"

  disk_type = "${var.tectonic_gcp_master_disktype}"
  disk_size = "${var.tectonic_gcp_master_disk_size}"

  ign_k8s_node_bootstrap_service_id = "${module.ignition_masters.k8s_node_bootstrap_service_id}"
  ign_bootkube_path_unit_id         = "${module.bootkube.systemd_path_unit_id}"
  ign_bootkube_service_id           = "${module.bootkube.systemd_service_id}"
  ign_docker_dropin_id              = "${module.ignition_masters.docker_dropin_id}"
  ign_kubelet_service_id            = "${module.ignition_masters.kubelet_service_id}"
  ign_locksmithd_service_id         = "${module.ignition_masters.locksmithd_service_id}"
  ign_max_user_watches_id           = "${module.ignition_masters.max_user_watches_id}"
  ign_installer_kubelet_env_id      = "${module.ignition_masters.installer_kubelet_env_id}"
  ign_tectonic_path_unit_id         = "${var.tectonic_vanilla_k8s ? "" : module.tectonic.systemd_path_unit_id}"
  ign_tectonic_service_id           = "${module.tectonic.systemd_service_id}"
  image_re                          = "${var.tectonic_image_re}"
  container_images                  = "${var.tectonic_container_images}"
}

module "workers" {
  source = "../../modules/gcp/worker-igm"

  region             = "${var.tectonic_gcp_region}"
  instance_count     = "${var.tectonic_worker_count}"
  machine_type       = "${var.tectonic_gcp_worker_gce_type}"
  cluster_name       = "${var.tectonic_cluster_name}"
  public_ssh_key     = "${var.tectonic_gcp_ssh_key}"
  kubeconfig_content = "${module.bootkube.kubeconfig}"

  worker_subnetwork_name      = "${module.network.worker_subnetwork_name}"
  worker_targetpool_self_link = "${module.network.worker_targetpool_self_link}"

  cl_channel = "${var.tectonic_container_linux_channel}"

  disk_type = "${var.tectonic_gcp_worker_disktype}"
  disk_size = "${var.tectonic_gcp_worker_disk_size}"

  ign_k8s_node_bootstrap_service_id = "${module.ignition_workers.k8s_node_bootstrap_service_id}"
  ign_installer_kubelet_env_id      = "${module.ignition_workers.installer_kubelet_env_id}"
  ign_docker_dropin_id              = "${module.ignition_workers.docker_dropin_id}"
  ign_kubelet_service_id            = "${module.ignition_workers.kubelet_service_id}"
  ign_locksmithd_service_id         = "${module.ignition_masters.locksmithd_service_id}"
  ign_max_user_watches_id           = "${module.ignition_workers.max_user_watches_id}"
  ign_installer_kubelet_env_id      = "${module.ignition_workers.installer_kubelet_env_id}"
}

module "ignition_masters" {
  source = "../../modules/ignition"

  cluster_name         = "${var.tectonic_cluster_name}"
  bootstrap_upgrade_cl = "${var.tectonic_bootstrap_upgrade_cl}"
  tectonic_vanilla_k8s = "${var.tectonic_vanilla_k8s}"
  container_images     = "${var.tectonic_container_images}"
  image_re             = "${var.tectonic_image_re}"
  kube_dns_service_ip  = "${module.bootkube.kube_dns_service_ip}"

  kubelet_cni_bin_dir = "${var.tectonic_networking == "calico" || var.tectonic_networking == "canal" ? "/var/lib/cni/bin" : "" }"
  kubelet_node_label  = "node-role.kubernetes.io/master"
  kubelet_node_taints = "node-role.kubernetes.io/master=:NoSchedule"

  etcd_advertise_name_list  = "${data.template_file.etcd_hostname_list.*.rendered}"
  etcd_count                = "${length(data.template_file.etcd_hostname_list.*.id)}"
  etcd_initial_cluster_list = "${data.template_file.etcd_hostname_list.*.rendered}"
  etcd_tls_enabled          = "${var.tectonic_etcd_tls_enabled}"
}

module "ignition_workers" {
  source = "../../modules/ignition"

  cluster_name         = "${var.tectonic_cluster_name}"
  bootstrap_upgrade_cl = "${var.tectonic_bootstrap_upgrade_cl}"
  tectonic_vanilla_k8s = "${var.tectonic_vanilla_k8s}"
  container_images     = "${var.tectonic_container_images}"
  image_re             = "${var.tectonic_image_re}"
  kube_dns_service_ip  = "${module.bootkube.kube_dns_service_ip}"

  kubelet_cni_bin_dir = "${var.tectonic_networking == "calico" || var.tectonic_networking == "canal" ? "/var/lib/cni/bin" : "" }"
  kubelet_node_label  = "node-role.kubernetes.io/node"
  kubelet_node_taints = ""
}

module "dns" {
  source = "../../modules/dns/gcp"

  cluster_name        = "${var.tectonic_cluster_name}"
  etcd_dns_enabled    = "${var.tectonic_self_hosted_etcd == "" && length(compact(var.tectonic_etcd_servers)) == 0}"
  tls_enabled         = "${var.tectonic_etcd_tls_enabled}"
  external_endpoints  = ["${compact(var.tectonic_etcd_servers)}"]
  etcd_instance_count = "${var.tectonic_self_hosted_etcd != "" ? 0 : var.tectonic_etcd_count > 0 ? var.tectonic_etcd_count : length(data.google_compute_zones.available.names) == 5 ? 5 : 3}"
  managed_zone_name   = "${var.tectonic_gcp_ext_google_managedzone_name}"
  etcd_ip_addresses   = "${module.etcd.etcd_ip_addresses}"
  base_domain         = "${var.tectonic_base_domain}"
  tectonic_masters_ip = "${module.network.master_ip}"
  tectonic_ingress_ip = "${module.network.ingress_ip}"
}
