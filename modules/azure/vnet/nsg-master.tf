resource "azurerm_network_security_group" "master" {
  count               = "${var.external_master_nsg_name == "" ? 1 : 0}"
  name                = "${var.tectonic_cluster_name}-master-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "master_egress" {
  name                        = "${var.tectonic_cluster_name}-master_egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_ssh" {
  name                        = "${var.tectonic_cluster_name}-master_ingress_ssh"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_internal}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

# TODO: Add external SSH rule
resource "azurerm_network_security_rule" "master_ingress_ssh_admin" {
  name                        = "${var.tectonic_cluster_name}-master_ingress_ssh_admin"
  priority                    = 250
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_external}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_flannel" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_flannel"
  priority               = 300
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "udp"
  source_port_range      = "*"
  destination_port_range = "4789"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_flannel_from_worker" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_flannel_from_worker"
  priority               = 400
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "udp"
  source_port_range      = "*"
  destination_port_range = "4789"

  # TODO: Need to allow traffic from worker
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

# TODO: Add rule(s) for Tectonic ingress

resource "azurerm_network_security_rule" "master_ingress_node_exporter" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_node_exporter"
  priority               = 700
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "9100"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_node_exporter_from_worker" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_node_exporter_from_worker"
  priority               = 800
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "9100"

  # TODO: Need to allow traffic from worker
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_services" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_services"
  priority               = 900
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "30000-32767"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_services_from_console" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_services_from_console"
  priority               = 1000
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "30000-32767"

  # TODO: Need to allow traffic from console
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_etcd_lb" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_etcd"
  priority               = 1100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "2379"

  source_address_prefix       = "*"
  destination_address_prefix  = "*"                               #"${var.etcd_lb_ip}"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_etcd_self" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_etcd_self"
  priority               = 1150
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "2379-2380"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_bootstrap_etcd" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_bootstrap_etcd"
  priority               = 1200
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "12379-12380"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_insecure" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_kubelet_insecure"
  priority               = 1300
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "10250"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_insecure_from_worker" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_kubelet_insecure_from_worker"
  priority               = 1400
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "10250"

  # TODO: Need to allow traffic from worker
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_secure" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_kubelet_secure"
  priority               = 1500
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "10255"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_secure_from_worker" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_kubelet_secure_from_worker"
  priority               = 1600
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "10255"

  # TODO: Need to allow traffic from worker
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

# TODO: Review NSG
resource "azurerm_network_security_rule" "master_ingress_http" {
  name                        = "${var.tectonic_cluster_name}-master_ingress_http"
  priority                    = 1700
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

# TODO: Review NSG
resource "azurerm_network_security_rule" "master_ingress_https" {
  name                        = "${var.tectonic_cluster_name}-master_ingress_https"
  priority                    = 1800
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

# TODO: Review NSG
resource "azurerm_network_security_rule" "master_ingress_heapster" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_heapster"
  priority               = 1900
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "4194"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}

# TODO: Review NSG
resource "azurerm_network_security_rule" "master_ingress_heapster_from_worker" {
  name                   = "${var.tectonic_cluster_name}-master_ingress_heapster_from_worker"
  priority               = 2000
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "4194"

  # TODO: Need to allow traffic from worker
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name}"
}
