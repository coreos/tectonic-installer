variable "tectonic_azure_location" {
  default = "eastus"
}

variable "tectonic_azure_vnet_cidr_block" {
  default = "10.0.0.0/16"
}

resource "azurerm_resource_group" "integ_external_net" {
  name     = "integ_external_net"
  location = "${var.tectonic_azure_location}"
}

resource "azurerm_virtual_network" "integ_external_net" {
  name                = "integ_external_net"
  resource_group_name = "${azurerm_resource_group.integ_external_net.name}"
  address_space       = ["${var.tectonic_azure_vnet_cidr_block}"]
  location            = "${var.tectonic_azure_location}"
}

resource "azurerm_subnet" "integ_external_master_subnet" {
  name                      = "integ_external_master_subnet"
  resource_group_name       = "${azurerm_resource_group.integ_external_net.name}"
  virtual_network_name      = "${azurerm_virtual_network.integ_external_net.name}"
  address_prefix            = "${cidrsubnet(var.tectonic_azure_vnet_cidr_block, 4, 0)}"
  network_security_group_id = "${azurerm_network_security_group.integ_external_sg_master.id}"
}

resource "azurerm_subnet" "integ_external_worker_subnet" {
  name                      = "integ_external_worker_subnet"
  resource_group_name       = "${azurerm_resource_group.integ_external_net.name}"
  virtual_network_name      = "${azurerm_virtual_network.integ_external_net.name}"
  address_prefix            = "${cidrsubnet(var.tectonic_azure_vnet_cidr_block, 4, 1)}"
  network_security_group_id = "${azurerm_network_security_group.integ_external_sg_worker.id}"
}

resource "azurerm_network_security_group" "integ_external_sg_master" {
  name                = "integ_external_sg_master"
  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${azurerm_resource_group.integ_external_net.name}"
}

resource "azurerm_network_security_group" "integ_external_sg_worker" {
  name                = "integ_external_sg_worker"
  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${azurerm_resource_group.integ_external_net.name}"
}

resource "azurerm_network_security_group" "integ_external_sg_api" {
  name                = "integ_external_sg_api"
  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${azurerm_resource_group.integ_external_net.name}"
}

output "tectonic_azure_external_resource_group" {
  value = "${azurerm_resource_group.integ_external_net.id}"
}

output "tectonic_azure_external_vnet_id" {
  value = "${azurerm_virtual_network.integ_external_net.id}"
}

output "tectonic_azure_external_master_subnet_id" {
  value = "${azurerm_subnet.integ_external_master_subnet.id}"
}

output "tectonic_azure_external_worker_subnet_id" {
  value = "${azurerm_subnet.integ_external_worker_subnet.id}"
}

output "tectonic_azure_external_nsg_api_id" {
  value = "${azurerm_network_security_group.integ_external_sg_api.id}"
}

output "tectonic_azure_external_nsg_master_id" {
  value = "${azurerm_network_security_group.integ_external_sg_master.id}"
}

output "tectonic_azure_external_nsg_worker_id" {
  value = "${azurerm_network_security_group.integ_external_sg_worker.id}"
}
