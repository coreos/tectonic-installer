module "resource_group" {
  source = "../../modules/azure/resource-group"

  external_rsg_name       = "${var.tectonic_azure_external_rsg_name}"
  tectonic_azure_location = "${var.tectonic_azure_location}"
  cluster_name            = "${var.tectonic_cluster_name}"
}

module "vnet" {
  source = "../../modules/azure/vnet"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${module.resource_group.name}"
  cluster_name        = "${var.tectonic_cluster_name}"
  vnet_cidr_block     = "${var.tectonic_cluster_cidr}"

  etcd_count                = "${var.tectonic_experimental ? 0 : var.tectonic_etcd_count}"
  master_count              = "${var.tectonic_master_count}"
  worker_count              = "${var.tectonic_worker_count}"
  etcd_cidr                 = "${module.vnet.etcd_cidr}"
  master_cidr               = "${module.vnet.master_cidr}"
  worker_cidr               = "${module.vnet.worker_cidr}"
  external_vnet_name        = "${var.tectonic_azure_external_vnet_name}"
  external_master_subnet_id = "${var.tectonic_azure_external_master_subnet_id}"
  external_worker_subnet_id = "${var.tectonic_azure_external_worker_subnet_id}"
  ssh_network_internal      = "${var.tectonic_azure_ssh_network_internal}"
  ssh_network_external      = "${var.tectonic_azure_ssh_network_external}"
  external_resource_group   = "${var.tectonic_azure_external_resource_group}"
  external_nsg_etcd         = "${var.tectonic_azure_external_nsg_etcd}"
  external_nsg_api          = "${var.tectonic_azure_external_nsg_api}"
  external_nsg_master       = "${var.tectonic_azure_external_nsg_master}"
  external_nsg_worker       = "${var.tectonic_azure_external_nsg_worker}"
}

module "etcd" {
  source = "../../modules/azure/etcd"

  location             = "${var.tectonic_azure_location}"
  resource_group_name  = "${module.resource_group.name}"
  vm_size              = "${var.tectonic_azure_etcd_vm_size}"
  storage_account_type = "${var.tectonic_azure_etcd_storage_account_type}"

  etcd_count            = "${var.tectonic_experimental ? 0 : var.tectonic_etcd_count}"
  base_domain           = "${var.tectonic_base_domain}"
  cluster_name          = "${var.tectonic_cluster_name}"
  public_ssh_key        = "${var.tectonic_azure_ssh_key}"
  endpoints             = "${module.vnet.etcd_endpoints}"
  network_interface_ids = "${module.vnet.etcd_network_interface_ids}"
  versions              = "${var.tectonic_versions}"
}

module "masters" {
  source = "../../modules/azure/master-as"

  location             = "${var.tectonic_azure_location}"
  resource_group_name  = "${module.resource_group.name}"
  vm_size              = "${var.tectonic_azure_master_vm_size}"
  storage_account_type = "${var.tectonic_azure_master_storage_account_type}"

  master_count                 = "${var.tectonic_master_count}"
  base_domain                  = "${var.tectonic_base_domain}"
  cluster_name                 = "${var.tectonic_cluster_name}"
  public_ssh_key               = "${var.tectonic_azure_ssh_key}"
  virtual_network              = "${module.vnet.vnet_id}"
  network_interface_ids        = "${module.vnet.master_network_interface_ids}"
  vnet_cidr_block              = "${var.tectonic_cluster_cidr}"
  kube_image_url               = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$1")}"
  kube_image_tag               = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$2")}"
  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  tectonic_kube_dns_service_ip = "${module.bootkube.kube_dns_service_ip}"
  cloud_provider               = ""
  kubelet_node_label           = "node-role.kubernetes.io/master"
  kubelet_node_taints          = "node-role.kubernetes.io/master=:NoSchedule"
  bootkube_service             = "${module.bootkube.systemd_service}"
  tectonic_service             = "${module.tectonic.systemd_service}"
  tectonic_service_disabled    = "${var.tectonic_vanilla_k8s}"
  versions                     = "${var.tectonic_versions}"
}

module "workers" {
  source = "../../modules/azure/worker-as"

  location             = "${var.tectonic_azure_location}"
  resource_group_name  = "${module.resource_group.name}"
  vm_size              = "${var.tectonic_azure_worker_vm_size}"
  storage_account_type = "${var.tectonic_azure_worker_storage_account_type}"

  worker_count                 = "${var.tectonic_worker_count}"
  cluster_name                 = "${var.tectonic_cluster_name}"
  public_ssh_key               = "${var.tectonic_azure_ssh_key}"
  virtual_network              = "${module.vnet.vnet_id}"
  network_interface_ids        = "${module.vnet.worker_network_interface_ids}"
  kube_image_url               = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$1")}"
  kube_image_tag               = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$2")}"
  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  tectonic_kube_dns_service_ip = "${module.bootkube.kube_dns_service_ip}"
  cloud_provider               = ""
  kubelet_node_label           = "node-role.kubernetes.io/node"
  versions                     = "${var.tectonic_versions}"
}

module "dns" {
  source = "../../modules/azure/dns"

  master_ip_addresses = "${module.vnet.master_ip_addresses}"
  console_ip_address  = "${module.vnet.console_ip_address}"

  base_domain  = "${var.tectonic_base_domain}"
  cluster_name = "${var.tectonic_cluster_name}"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${var.tectonic_azure_dns_resource_group == "" ? module.resource_group.name : var.tectonic_azure_dns_resource_group}"
  external_dns_zone   = "${var.tectonic_azure_external_dns_zone}"
}
