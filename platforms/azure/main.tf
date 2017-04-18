resource "azurerm_resource_group" "tectonic_cluster" {
  location = "${var.tectonic_azure_location}"
  name     = "tectonic-cluster-${var.tectonic_cluster_name}"
}

module "vnet" {
  source = "../../modules/azure/vnet"

  location              = "${var.tectonic_azure_location}"
  resource_group_name   = "${azurerm_resource_group.tectonic_cluster.name}"
  tectonic_cluster_name = "${var.tectonic_cluster_name}"
  vnet_cidr_block       = "${var.tectonic_azure_vnet_cidr_block}"
}

module "etcd" {
  source = "../../modules/azure/etcd"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${azurerm_resource_group.tectonic_cluster.name}"
  image_reference     = "${var.tectonic_azure_image_reference}"
  vm_size             = "${var.tectonic_azure_etcd_vm_size}"

  etcd_count      = "${var.tectonic_etcd_count}"
  base_domain     = "${var.tectonic_base_domain}"
  cluster_name    = "${var.tectonic_cluster_name}"
  ssh_key         = "${var.tectonic_azure_ssh_key}"
  virtual_network = "${module.vnet.vnet_id}"
  subnet          = "${module.vnet.master_subnet}"
}

module "masters" {
  source = "../../modules/azure/master"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${azurerm_resource_group.tectonic_cluster.name}"
  image_reference     = "${var.tectonic_azure_image_reference}"
  vm_size             = "${var.tectonic_azure_master_vm_size}"

  master_count                 = "${var.tectonic_master_count}"
  base_domain                  = "${var.tectonic_base_domain}"
  cluster_name                 = "${var.tectonic_cluster_name}"
  public_ssh_key               = "${var.tectonic_azure_ssh_key}"
  virtual_network              = "${module.vnet.vnet_id}"
  subnet                       = "${module.vnet.master_subnet}"
  kube_image_url               = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
  kube_image_tag               = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
  etcd_endpoints               = ["${module.etcd.ip_address}"]
  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  tectonic_versions            = "${var.tectonic_versions}"
  tectonic_kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  cloud_provider               = ""
  kubelet_node_label           = "node-role.kubernetes.io/master"
  bootkube_service             = "${module.bootkube.systemd_service}"
  tectonic_service             = "${module.tectonic.systemd_service}"
  tectonic_service_disabled    = "${var.tectonic_vanilla_k8s}"
}

module "workers" {
  source = "../../modules/azure/worker"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${azurerm_resource_group.tectonic_cluster.name}"
  image_reference     = "${var.tectonic_azure_image_reference}"
  vm_size             = "${var.tectonic_azure_worker_vm_size}"

  worker_count                 = "${var.tectonic_worker_count}"
  base_domain                  = "${var.tectonic_base_domain}"
  cluster_name                 = "${var.tectonic_cluster_name}"
  public_ssh_key               = "${var.tectonic_azure_ssh_key}"
  virtual_network              = "${module.vnet.vnet_id}"
  subnet                       = "${module.vnet.worker_subnet}"
  kube_image_url               = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
  kube_image_tag               = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
  etcd_endpoints               = ["${module.etcd.ip_address}"]
  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  tectonic_versions            = "${var.tectonic_versions}"
  tectonic_kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  cloud_provider               = ""
  kubelet_node_label           = "node-role.kubernetes.io/node"
}

module "dns" {
  source = "../../modules/azure/dns"

  master_ip_addresses = "${module.masters.ip_address}"
  console_ip_address  = "${module.masters.console_ip_address}"
  etcd_ip_addresses   = "${module.etcd.ip_address}"

  base_domain  = "${var.tectonic_base_domain}"
  cluster_name = "${var.tectonic_cluster_name}"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${var.tectonic_azure_dns_resource_group}"

  create_dns_zone = "${var.tectonic_azure_create_dns_zone}"

  // TODO etcd list
  // TODO worker list
}
