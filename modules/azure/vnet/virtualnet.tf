resource "azurerm_virtual_network" "tectonic_vnet" {
  count               = "${var.external_vnet_name == "" ? 1 :0 }"
  name                = "${var.tectonic_cluster_name}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["${var.vnet_cidr_block}"]
  location            = "${var.location}"
}

resource "azurerm_subnet" "master_subnet" {
  count                = "${var.external_vnet_name == "" ? 1 : 0}"
  name                 = "${var.tectonic_cluster_name}_master_subnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.external_vnet_name == "" ? join("",azurerm_virtual_network.tectonic_vnet.*.name) : var.external_vnet_name }"
  address_prefix       = "${cidrsubnet(var.vnet_cidr_block, 4, 0)}"
  network_security_group_id = "${azurerm_network_security_group.master.id}"
}

resource "azurerm_subnet" "worker_subnet" {
  count                = "${var.external_vnet_name == "" ? 1 : 0}"
  name                 = "${var.tectonic_cluster_name}_worker_subnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.external_vnet_name == "" ? join("",azurerm_virtual_network.tectonic_vnet.*.name) : var.external_vnet_name }"
  address_prefix       = "${cidrsubnet(var.vnet_cidr_block, 4, 1)}"
  network_security_group_id = "${azurerm_network_security_group.worker.id}"
}

# TODO: Add NSG ID
# TODO: Review if we actually need an additional subnet for this
resource "azurerm_subnet" "admin_subnet" {
  count                = "${var.external_vnet_name == "" ? 1 : 0}"
  name                 = "${var.tectonic_cluster_name}_admin_subnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.external_vnet_name == "" ? join("",azurerm_virtual_network.tectonic_vnet.*.name) : var.external_vnet_name }"
  address_prefix       = "${cidrsubnet(var.vnet_cidr_block, 4, 2)}"
}
