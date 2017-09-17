resource "azurerm_network_security_group" "etcd" {
  count               = "${var.external_nsg_etcd_id == "" && var.etcd_count > 0 ? 1 : 0}"
  name                = "${var.cluster_name}-etcd"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "etcd_egress" {
  count                       = "${var.external_nsg_etcd_id == "" && var.etcd_count > 0 ? 1 : 0}"
  name                        = "${var.cluster_name}-etcd-out"
  priority                    = 2000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.etcd.name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_ssh" {
  count                       = "${var.external_nsg_etcd_id == "" && var.etcd_count > 0 ? 1 : 0}"
  name                        = "${var.cluster_name}-etcd-in-ssh-internal"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_internal}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.etcd.name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_ssh_admin" {
  count                       = "${var.external_nsg_etcd_id == "" && var.etcd_count > 0 ? 1 : 0}"
  name                        = "${var.cluster_name}-etcd-in-ssh-external"
  priority                    = 405
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_external}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.etcd.name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_ssh_from_master" {
  count                       = "${var.external_nsg_etcd_id == "" && var.etcd_count > 0 ? 1 : 0}"
  name                        = "${var.cluster_name}-etcd-in-ssh-master"
  priority                    = 415
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.etcd.name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_client_self" {
  count                       = "${var.external_nsg_etcd_id == "" && var.etcd_count > 0 ? 1 : 0}"
  name                        = "${var.cluster_name}-etcd-in_client_self"
  priority                    = 420
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "2379"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.etcd.name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_client_master" {
  count                       = "${var.external_nsg_etcd_id == "" && var.etcd_count > 0 ? 1 : 0}"
  name                        = "${var.cluster_name}-etcd-in_client_master"
  priority                    = 425
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "2379"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.etcd.name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_client_worker" {
  count                       = "${var.external_nsg_etcd_id == "" && var.etcd_count > 0 ? 1 : 0}"
  name                        = "${var.cluster_name}-etcd-in_client_worker"
  priority                    = 430
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "2379"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.etcd.name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_peer" {
  count                       = "${var.external_nsg_etcd_id == "" && var.etcd_count > 0 ? 1 : 0}"
  name                        = "${var.cluster_name}-etcd-in_peer"
  priority                    = 435
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "2380"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.etcd.name}"
}
