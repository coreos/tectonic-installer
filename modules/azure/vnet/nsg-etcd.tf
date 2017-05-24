resource "azurerm_network_security_group" "etcd" {
  count               = "${var.external_etcd_nsg_name == "" ? 1 : 0}"
  name                = "${var.tectonic_cluster_name}-etcd-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  #depends_on          = ["azurerm_subnet.master_subnet.id"]
}

resource "azurerm_network_security_rule" "etcd_egress" {
  name                        = "${var.tectonic_cluster_name}-etcd_egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_etcd_nsg_name}"
}

# TODO: Remove in lieu of below rules
#resource "azurerm_network_security_rule" "etcd_ingress_ssh" {
#  name                        = "${var.tectonic_cluster_name}-etcd_ingress_ssh"
#  priority                    = 300
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "*"
#  destination_port_range      = "22"
#  source_address_prefix       = "*"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_nsg_rsg_name}"
#  network_security_group_name = "${var.external_etcd_nsg_name}"
#}

resource "azurerm_network_security_rule" "etcd_ingress_ssh" {
  name                        = "${var.tectonic_cluster_name}-etcd_ingress_ssh"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_internal}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_etcd_nsg_name}"
}

# TODO: Add external SSH rule
resource "azurerm_network_security_rule" "etcd_ingress_ssh_admin" {
  name                        = "${var.tectonic_cluster_name}-etcd_ingress_ssh_admin"
  priority                    = 250
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_external}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_etcd_nsg_name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_ssh_self" {
  name                   = "${var.tectonic_cluster_name}-etcd_ingress_ssh_self"
  priority               = 300
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "22"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_etcd_nsg_name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_ssh_from_master" {
  name                   = "${var.tectonic_cluster_name}-etcd_ingress_services_from_console"
  priority               = 400
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "22"

  # TODO: Need to allow traffic from master
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_etcd_nsg_name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_client_self" {
  name                   = "${var.tectonic_cluster_name}-etcd_ingress_client_self"
  priority               = 500
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "2379"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_etcd_nsg_name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_client_master" {
  name                   = "${var.tectonic_cluster_name}-etcd_ingress_client_master"
  priority               = 600
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "2379"

  # TODO: Need to allow traffic from master
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_etcd_nsg_name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_client_worker" {
  name                   = "${var.tectonic_cluster_name}-etcd_ingress_client_worker"
  priority               = 700
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "2379"

  # TODO: Need to allow traffic from workers
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_etcd_nsg_name}"
}

resource "azurerm_network_security_rule" "etcd_ingress_peer" {
  name                   = "${var.tectonic_cluster_name}-etcd_ingress_peer"
  priority               = 800
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "2380"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_etcd_nsg_name}"
}
