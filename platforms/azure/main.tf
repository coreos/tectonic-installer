# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "59275c1f-d506-40e9-9d1d-ab958f3110ab"
  client_id       = "9301d64e-c2b6-46c9-9d0d-64e8f27d562f"
  client_secret   = "79e72594-0b70-4acb-bd75-8061bb07db1b"
  tenant_id       = "72f988bf-86f1-41af-91ab-2d7cd011db47"
}

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
  ssh_key         = "${var.tectonic_ssh_key}"
  virtual_network = "${module.vnet.vnet_id}"
  subnet          = "${module.vnet.master_subnet}"
}

module "masters" {
  source = "../../modules/azure/master"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${azurerm_resource_group.tectonic_cluster.name}"
  image_reference     = "${var.tectonic_azure_image_reference}"
  vm_size             = "${var.tectonic_azure_master_vm_size}"

  master_count    = "${var.tectonic_master_count}"
  base_domain     = "${var.tectonic_base_domain}"
  cluster_name    = "${var.tectonic_cluster_name}"
  public_ssh_key  = "${var.tectonic_azure_ssh_key}"
  virtual_network = "${module.vnet.vnet_id}"
  subnet          = "${module.vnet.master_subnet}"
  kube_image_url  = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
  kube_image_tag  = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"

  # kube_config     = "${module.bootkube.kubeconfig}"
}

module "workers" {
  source = "../../modules/azure/worker"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${azurerm_resource_group.tectonic_cluster.name}"
  image_reference     = "${var.tectonic_azure_image_reference}"
  vm_size             = "${var.tectonic_azure_worker_vm_size}"

  worker_count    = "${var.tectonic_worker_count}"
  base_domain     = "${var.tectonic_base_domain}"
  cluster_name    = "${var.tectonic_cluster_name}"
  public_ssh_key  = "${var.tectonic_azure_ssh_key}"
  virtual_network = "${module.vnet.vnet_id}"
  subnet          = "${module.vnet.worker_subnet}"
  kube_image_url  = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
  kube_image_tag  = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"

  # kube_config     = "${module.bootkube.kubeconfig}"
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

  // TODO etcd list
  // TODO worker list
}
