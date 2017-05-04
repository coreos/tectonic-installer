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
  project     = "${var.tectonic_gcp_project_id}"
  region      = "${var.tectonic_gcp_region}"
  credentials = "${var.tectonic_gcp_credentials}"
}

module "network" {
  source = "../../modules/google/network"

  gcp_region           = "${var.tectonic_gcp_region}"
  master_ip_cidr_range = "${var.tectonic_gcp_network_masters_cidr_range}"
  worker_ip_cidr_range = "${var.tectonic_gcp_network_workers_cidr_range}"

  managed_zone_name = "${var.google_managedzone_name}"
  base_domain       = "${var.tectonic_base_domain}"
  cluster_name      = "${var.tectonic_cluster_name}"

  # VPC layout settings.
  #
  # The following parameters control the layout of the VPC accross availability zones.
  # Two modes are available:
  # A. Explicitly configure a list of AZs + associated subnet CIDRs
  # B. Let the module calculate subnets accross a set number of AZs
  #
  # To enable mode A, make sure "tectonic_gcp_az_count" variable IS NOT SET to any value
  # and instead configure a set of AZs + CIDRs for masters and workers using the
  # "tectonic_gcp_master_custom_subnets" and "tectonic_gcp_worker_custom_subnets" variables.
  #
  # To enable mode B, make sure that "tectonic_gcp_master_custom_subnets" and "tectonic_gcp_worker_custom_subnets"
  # ARE NOT SET. Instead, set the desired number of VPC AZs using "tectonic_gcp_az_count" variable.

  # These counts could be deducted by length(keys(var.tectonic_gcp_master_custom_subnets))
  # but there is a restriction on passing computed values as counts. This approach works around that.
  #master_az_count = "${var.tectonic_gcp_az_count == "" ? "${length(keys(var.tectonic_gcp_master_custom_subnets))}" : var.tectonic_gcp_az_count}"
  #worker_az_count = "${var.tectonic_gcp_az_count == "" ? "${length(keys(var.tectonic_gcp_worker_custom_subnets))}" : var.tectonic_gcp_az_count}"
  # The appending of the "padding" element is required as workaround since the function
  # element() won't work on empty lists. See https://github.com/hashicorp/terraform/issues/11210
  #master_subnets = "${concat(values(var.tectonic_gcp_master_custom_subnets),list("padding"))}"
  #worker_subnets = "${concat(values(var.tectonic_gcp_worker_custom_subnets),list("padding"))}"
  # The split() / join() trick works around the limitation of tenrary operator expressions 
  # only being able to return strings.
  #master_azs = ["${ split("|", "${length(keys(var.tectonic_gcp_master_custom_subnets))}" > 0 ?
  #  join("|", keys(var.tectonic_gcp_master_custom_subnets)) :
  #  join("|", data.gcp_availability_zones.azs.names)
  #)}"]
  #worker_azs = ["${ split("|", "${length(keys(var.tectonic_gcp_worker_custom_subnets))}" > 0 ?
  #  join("|", keys(var.tectonic_gcp_worker_custom_subnets)) :
  #  join("|", data.gcp_availability_zones.azs.names)
  #)}"]
}

module "etcd" {
  source = "../../modules/google/etcd"

  zone_list      = "${var.tectonic_gcp_zones}"
  machine_type   = "${var.tectonic_gcp_etcd_gce_type}"
  managed_zone_name = "${var.google_managedzone_name}"
  cluster_name   = "${var.tectonic_cluster_name}"
  base_domain     = "${var.tectonic_base_domain}"
  container_image = "${var.tectonic_container_images["etcd"]}"

  cl_channel = "${var.tectonic_cl_channel}"

  disk_type = "${var.tectonic_gcp_etcd_disktype}"
  disk_size = "${var.tectonic_gcp_etcd_disk_size}"

  master_subnetwork_name = "${module.network.master_subnetwork_name}"
}

module "masters" {
  source = "../../modules/google/master-mig"

  project_id     = "${var.tectonic_gcp_project_id}"
  instance_count = "${var.tectonic_master_count}"
  zone_list      = "${var.tectonic_gcp_zones}"
  max_masters    = "${var.tectonic_masters_max}"
  machine_type   = "${var.tectonic_gcp_master_gce_type}"
  cluster_name   = "${var.tectonic_cluster_name}"
  user_data      = "${module.ignition-masters.ignition}"

  master_subnetwork_name = "${module.network.master_subnetwork_name}"
  master_targetpool_self_link = "${module.network.master_targetpool_self_link}"

  cl_channel = "${var.tectonic_cl_channel}"

  base_domain     = "${var.tectonic_base_domain}"
  custom_dns_name = "${var.tectonic_dns_prefix_name}"

  disk_type = "${var.tectonic_gcp_master_disktype}"
  disk_size = "${var.tectonic_gcp_master_disk_size}"
}

module "workers" {
  source = "../../modules/google/worker-mig"

  instance_count = "${var.tectonic_worker_count}"
  zone_list      = "${var.tectonic_gcp_zones}"
  max_workers    = "${var.tectonic_workers_max}"
  machine_type   = "${var.tectonic_gcp_worker_gce_type}"
  cluster_name   = "${var.tectonic_cluster_name}"
  user_data      = "${module.ignition-workers.ignition}"

  worker_subnetwork_name = "${module.network.worker_subnetwork_name}"
  worker_targetpool_self_link = "${module.network.worker_targetpool_self_link}"

  cl_channel = "${var.tectonic_cl_channel}"

  base_domain     = "${var.tectonic_base_domain}"
  custom_dns_name = "${var.tectonic_dns_prefix_name}"

  disk_type = "${var.tectonic_gcp_worker_disktype}"
  disk_size = "${var.tectonic_gcp_worker_disk_size}"
}

module "ignition-masters" {
  source = "../../modules/google/ignition"

  kubelet_node_label        = "node-role.kubernetes.io/master"
  kubelet_node_taints       = "node-role.kubernetes.io/master=:NoSchedule"
  kube_dns_service_ip       = "${var.tectonic_kube_dns_service_ip}"
  etcd_endpoints            = ["${module.etcd.etcd_ip}"]
  kubeconfig_gcs_location   = "${google_storage_bucket.kubeconfig.name}/${google_storage_bucket_object.kubeconfig.name}"
  assets_gcs_location       = "${google_storage_bucket.tectonic-assets.name}/${google_storage_bucket_object.tectonic-assets.name}"
  container_images          = "${var.tectonic_container_images}"
  bootkube_service          = "${module.bootkube.systemd_service}"
  tectonic_service          = "${module.tectonic.systemd_service}"
  tectonic_service_disabled = "${var.tectonic_vanilla_k8s}"
  locksmithd_disabled       = "${var.tectonic_experimental}"
}

module "ignition-workers" {
  source = "../../modules/google/ignition"

  kubelet_node_label      = "node-role.kubernetes.io/node"
  kubelet_node_taints     = ""
  kube_dns_service_ip     = "${var.tectonic_kube_dns_service_ip}"
  etcd_endpoints          = ["${module.etcd.etcd_ip}"]
  kubeconfig_gcs_location = "${google_storage_bucket.kubeconfig.name}/${google_storage_bucket_object.kubeconfig.name}"
  assets_gcs_location     = ""
  container_images        = "${var.tectonic_container_images}"
  bootkube_service        = ""
  tectonic_service        = ""
  locksmithd_disabled     = "${var.tectonic_experimental}"
}

# vim: ts=2:sw=2:sts=2:et:ai
