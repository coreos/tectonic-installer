resource "azurerm_virtual_network" "tectonic_vnet" {
  count               = "${var.external_vnet_name == "" ? 1 :0 }"
  name                = "${var.tectonic_cluster_name}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["${var.vnet_cidr_block}"]
  location            = "${var.location}"
}

resource "azurerm_subnet" "master_subnet" {
  count                = "${var.external_vnet_name == "" ? 1 : 0}"
  name                 = "${var.tectonic_cluster_name}-master-subnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.external_vnet_name == "" ? join("",azurerm_virtual_network.tectonic_vnet.*.name) : var.external_vnet_name }"
  address_prefix       = "${cidrsubnet(var.vnet_cidr_block, 4, 0)}"
}

resource "azurerm_subnet" "worker_subnet" {
  count                = "${var.external_vnet_name == "" ? 1 : 0}"
  name                 = "${var.tectonic_cluster_name}-worker-subnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.external_vnet_name == "" ? join("",azurerm_virtual_network.tectonic_vnet.*.name) : var.external_vnet_name }"
  address_prefix       = "${cidrsubnet(var.vnet_cidr_block, 4, 1)}"
}

resource "azurerm_route_table" "tectonic" {
  name                = "${var.tectonic_cluster_name}-route-table"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}
