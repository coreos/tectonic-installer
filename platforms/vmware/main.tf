provider "vsphere" {
  user           = "${var.tectonic_vmware_username}"
  password       = "${var.tectonic_vmware_password}"
  vsphere_server = "${var.tectonic_vmware_server}"
  allow_unverified_ssl = "${var.tectonic_vmware_sslselfsigned}"
}

resource "vsphere_folder" "tectonic_vsphere_folder" {
  path = "${var.tectonic_vmware_folder}"
  datacenter = "${var.tectonic_vmware_datacenter}"
}

module "etcd" {
  source = "../../modules/vmware/etcd"

  count                   = "${var.tectonic_etcd_count}"
  cluster_name            = "${var.tectonic_cluster_name}"
  core_public_keys        = ["${module.secrets.core_public_key_openssh}"]
  container_image         = "${var.tectonic_container_images["etcd"]}"
  base_domain             = "${var.tectonic_base_domain}"
  external_endpoints      = ["${compact(var.tectonic_etcd_servers)}"]

  vmware_datacenter       = "${var.tectonic_vmware_datacenter}"
  vmware_cluster          = "${var.tectonic_vmware_cluster}"
  vm_vcpu                 = "${var.tectonic_vmware_etcd_vm_vcpu}"
  vm_memory               = "${var.tectonic_vmware_etcd_vm_memory}"
  vm_network_label        = "${var.tectonic_vmware_network}"
  vm_disk_datastore       = "${var.tectonic_vmware_datastore}"
  vm_disk_template        = "${var.tectonic_vmware_vm_template}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  vmware_folder           = "${var.tectonic_vmware_folder}"
  dns_server              = "${var.tectonic_vmware_vm_dns}"

  ip_address              = "${var.tectonic_vmware_vm_etcdips}"
  gateway                 = "${var.tectonic_vmware_vm_etcdgateway}"

}

module "masters" {
  source = "../../modules/vmware/master"

  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  cluster_name                 = "${var.tectonic_cluster_name}"
  count                        = "${var.tectonic_master_count}"
  kube_image_url               = "${data.null_data_source.local.outputs.kube_image_url}"
  kube_image_tag               = "${data.null_data_source.local.outputs.kube_image_tag}"
  tectonic_versions            = "${var.tectonic_versions}"
  base_domain             = "${var.tectonic_base_domain}"
  tectonic_kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  vmware_username              = "${var.tectonic_vmware_username}"
  vmware_password              = "${var.tectonic_vmware_password}"
  vmware_server                = "${var.tectonic_vmware_server}"
  vmware_sslselfsigned         = "${var.tectonic_vmware_sslselfsigned}"
  vmware_datastore             = "${var.tectonic_vmware_datastore}"
  vmware_datacenter            = "${var.tectonic_vmware_datacenter}"
  vmware_cluster               = "${var.tectonic_vmware_cluster}"
  vm_vcpu                 = "${var.tectonic_vmware_master_vm_vcpu}"
  vm_memory               = "${var.tectonic_vmware_master_vm_memory}"
  vm_network_label        = "${var.tectonic_vmware_network}"
  vm_disk_datastore       = "${var.tectonic_vmware_datastore}"
  vm_disk_template        = "${var.tectonic_vmware_vm_template}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  vmware_folder           = "${var.tectonic_vmware_folder}"
  etcd_fqdns              = ["${module.etcd.ip_address}"]
  dns_server              = "${var.tectonic_vmware_vm_dns}"
  ip_address              = "${var.tectonic_vmware_vm_masterips}"
  gateway                 = "${var.tectonic_vmware_vm_mastergateway}"

  core_public_keys = ["${module.secrets.core_public_key_openssh}"]
}

module "workers" {
  source = "../../modules/vmware/worker"

  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  cluster_name                 = "${var.tectonic_cluster_name}"
  count                        = "${var.tectonic_worker_count}"
  kube_image_url               = "${data.null_data_source.local.outputs.kube_image_url}"
  kube_image_tag               = "${data.null_data_source.local.outputs.kube_image_tag}"
  tectonic_versions            = "${var.tectonic_versions}"
  tectonic_kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  base_domain             = "${var.tectonic_base_domain}"
  vmware_username              = "${var.tectonic_vmware_username}"
  vmware_password              = "${var.tectonic_vmware_password}"
  vmware_server                = "${var.tectonic_vmware_server}"
  vmware_sslselfsigned         = "${var.tectonic_vmware_sslselfsigned}"
  vmware_datastore             = "${var.tectonic_vmware_datastore}"
  vmware_datacenter       = "${var.tectonic_vmware_datacenter}"
  vmware_cluster          = "${var.tectonic_vmware_cluster}"
  vm_vcpu                 = "${var.tectonic_vmware_worker_vm_vcpu}"
  vm_memory               = "${var.tectonic_vmware_worker_vm_memory}"
  vm_network_label        = "${var.tectonic_vmware_network}"
  vm_disk_datastore       = "${var.tectonic_vmware_datastore}"
  vm_disk_template        = "${var.tectonic_vmware_vm_template}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  vmware_folder           = "${var.tectonic_vmware_folder}"
  etcd_fqdns              = ["${module.etcd.ip_address}"]
  dns_server              = "${var.tectonic_vmware_vm_dns}"
  ip_address              = "${var.tectonic_vmware_vm_workerips}"
  gateway                 = "${var.tectonic_vmware_vm_workergateway}"
  core_public_keys = ["${module.secrets.core_public_key_openssh}"]
}

data "null_data_source" "local" {
  inputs = {
    kube_image_url = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
    kube_image_tag = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
  }
}

module "secrets" {
  source       = "../../modules/vmware/secrets"
  cluster_name = "${var.tectonic_cluster_name}"
}
