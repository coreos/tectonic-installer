data "null_data_source" "consts" {
  inputs = {
    master_as_name = "${var.tectonic_cluster_name}-master-availability-set"
  }
}

module "resource_group" {
  source = "../../modules/azure/resource-group"

  external_rsg_name       = "${var.tectonic_azure_external_rsg_name}"
  tectonic_azure_location = "${var.tectonic_azure_location}"
  tectonic_cluster_name   = "${var.tectonic_cluster_name}"
}

module "vnet" {
  source = "../../modules/azure/vnet"

  location                  = "${var.tectonic_azure_location}"
  resource_group_name       = "${module.resource_group.name}"
  tectonic_cluster_name     = "${var.tectonic_cluster_name}"
  vnet_cidr_block           = "${var.tectonic_azure_vnet_cidr_block}"
  external_vnet_name        = "${var.tectonic_azure_external_vnet_name}"
  external_master_subnet_id = "${var.tectonic_azure_external_master_subnet_id}"
  external_worker_subnet_id = "${var.tectonic_azure_external_worker_subnet_id}"
}

module "etcd" {
  source = "../../modules/azure/etcd"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${module.resource_group.name}"
  vm_size             = "${var.tectonic_azure_etcd_vm_size}"
  cl_channel          = "${var.tectonic_cl_channel}"

  etcd_count         = "${var.tectonic_experimental ? 0 : var.tectonic_etcd_count}"
  external_endpoints = ["${compact(var.tectonic_etcd_servers)}"]

  base_domain     = "${var.tectonic_base_domain}"
  cluster_name    = "${var.tectonic_cluster_name}"
  public_ssh_key  = "${var.tectonic_azure_ssh_key}"
  virtual_network = "${module.vnet.vnet_id}"
  subnet          = "${module.vnet.master_subnet}"

  container_image = "${element(split(":", var.tectonic_container_images["etcd"]), 1)}"
}

module "cloud-config" {
  source = "../../modules/azure/cloud-config"

  arm_cloud                     = "AzurePublicCloud"
  arm_client_secret             = "${var.tectonic_arm_client_secret}"
  resource_group_name           = "${module.resource_group.name}"
  location                      = "${var.tectonic_azure_location}"
  route_table_name              = "${module.vnet.route_table_name}"
  subnet_name                   = "${module.vnet.master_subnet_name}"
  nsg_name                      = "${module.vnet.security_group}"
  virtual_network               = "${module.vnet.vnet_id}"
  primary_availability_set_name = "${data.null_data_source.consts.outputs.master_as_name}"
}

module "ignition-masters" {
  source = "../../modules/azure/ignition"

  public_ssh_key                = "${var.tectonic_azure_ssh_key}"
  cloud_config              = "${module.cloud-config.content}"
  kubeconfig_content        = "${module.bootkube.kubeconfig}"
  kube_dns_service_ip       = "${var.tectonic_kube_dns_service_ip}"
  kubelet_node_label        = "node-role.kubernetes.io/master"
  kubelet_node_taints       = "node-role.kubernetes.io/master=:NoSchedule"
  kube_image_url            = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
  kube_image_tag            = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
  bootkube_service          = "${module.bootkube.systemd_service}"
  tectonic_service          = "${module.tectonic.systemd_service}"
  tectonic_service_disabled = "${var.tectonic_vanilla_k8s}"
}

module "masters" {
  source = "../../modules/azure/master"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${module.resource_group.name}"
  vm_size             = "${var.tectonic_azure_master_vm_size}"
  cl_channel          = "${var.tectonic_cl_channel}"

  master_count          = "${var.tectonic_master_count}"
  base_domain           = "${var.tectonic_base_domain}"
  cluster_name          = "${var.tectonic_cluster_name}"
  virtual_network       = "${module.vnet.vnet_id}"
  subnet                = "${module.vnet.master_subnet}"
  nsg_id                = "${module.vnet.security_group_id}"
  custom_data           = "${module.ignition-masters.ignition}"
  availability_set_name = "${data.null_data_source.consts.outputs.master_as_name}"
  public_ssh_key        = "${var.tectonic_azure_ssh_key}"
  public_ip_type        = "${var.tectonic_azure_public_ip_type}"
  use_custom_fqdn       = "${var.tectonic_azure_use_custom_fqdn}"
}

module "ignition-workers" {
  source = "../../modules/azure/ignition"

  public_ssh_key      = "${var.tectonic_azure_ssh_key}"
  cloud_config        = "${module.cloud-config.content}"
  kubeconfig_content  = "${module.bootkube.kubeconfig}"
  kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  kubelet_node_label  = "node-role.kubernetes.io/node"
  kubelet_node_taints = ""
  kube_image_url      = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
  kube_image_tag      = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
  bootkube_service    = ""
  tectonic_service    = ""
}

module "workers" {
  source = "../../modules/azure/worker"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${module.resource_group.name}"
  vm_size             = "${var.tectonic_azure_worker_vm_size}"
  cl_channel          = "${var.tectonic_cl_channel}"

  worker_count          = "${var.tectonic_worker_count}"
  base_domain           = "${var.tectonic_base_domain}"
  cluster_name          = "${var.tectonic_cluster_name}"
  virtual_network       = "${module.vnet.vnet_id}"
  subnet                = "${module.vnet.worker_subnet}"
  nsg_id                = "${module.vnet.security_group_id}"
  custom_data           = "${module.ignition-workers.ignition}"
  public_ssh_key        = "${var.tectonic_azure_ssh_key}"
}

module "dns" {
  source = "../../modules/azure/dns"

  public_ip_type = "${var.tectonic_azure_public_ip_type}"

  master_ip_address     = "${module.masters.ip_address}"
  master_azure_fqdn     = "${module.masters.api_azure_fqdn}"
  console_ip_address    = "${module.masters.console_ip_address}"
  console_azure_fqdn     = "${module.masters.console_azure_fqdn}"

  base_domain  = "${var.tectonic_base_domain}"
  cluster_name = "${var.tectonic_cluster_name}"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${var.tectonic_azure_dns_resource_group}"

  use_custom_fqdn   = "${var.tectonic_azure_use_custom_fqdn}"
  external_dns_zone = "${var.tectonic_azure_external_dns_zone}"

  // TODO etcd list
  // TODO worker list
}
