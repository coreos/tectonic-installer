resource "azurerm_network_security_group" "master" {
  count               = "${var.external_master_nsg_name == "" ? 1 : 0}"
  name                = "${var.tectonic_cluster_name}-master-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "master_egress" {
  count                       = "${var.create_master_nsg_rules ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-master_egress"
  priority                    = 2005
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_ssh" {
  count                       = "${var.create_master_nsg_rules ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-master_ingress_ssh"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_internal}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

# TODO: Add external SSH rule
resource "azurerm_network_security_rule" "master_ingress_ssh_admin" {
  count                       = "${var.create_master_nsg_rules ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-master_ingress_ssh_admin"
  priority                    = 505
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_external}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_flannel" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_flannel"
  priority               = 510
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "udp"
  source_port_range      = "*"
  destination_port_range = "4789"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_flannel_from_worker" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_flannel_from_worker"
  priority               = 515
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "udp"
  source_port_range      = "*"
  destination_port_range = "4789"

  # TODO: Need to allow traffic from worker
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

# TODO: Add rule(s) for Tectonic ingress

resource "azurerm_network_security_rule" "master_ingress_node_exporter" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_node_exporter"
  priority               = 520
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "9100"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_node_exporter_from_worker" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_node_exporter_from_worker"
  priority               = 525
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "9100"

  # TODO: Need to allow traffic from worker
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_services" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_services"
  priority               = 530
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "30000-32767"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_services_from_console" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_services_from_console"
  priority               = 535
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "30000-32767"

  # TODO: Need to allow traffic from console
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_etcd_lb" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_etcd"
  priority               = 540
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "2379"

  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_etcd_self" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_etcd_self"
  priority               = 545
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "2379-2380"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_bootstrap_etcd" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_bootstrap_etcd"
  priority               = 550
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "12379-12380"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_insecure" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_kubelet_insecure"
  priority               = 555
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "10250"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_insecure_from_worker" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_kubelet_insecure_from_worker"
  priority               = 560
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "10250"

  # TODO: Need to allow traffic from worker
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_secure" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_kubelet_secure"
  priority               = 565
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "10255"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_secure_from_worker" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_kubelet_secure_from_worker"
  priority               = 570
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "10255"

  # TODO: Need to allow traffic from worker
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

# TODO: Review NSG
resource "azurerm_network_security_rule" "master_ingress_http" {
  count                       = "${var.create_master_nsg_rules ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-master_ingress_http"
  priority                    = 575
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

# TODO: Review NSG
resource "azurerm_network_security_rule" "master_ingress_https" {
  count                       = "${var.create_master_nsg_rules ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-master_ingress_https"
  priority                    = 580
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

# TODO: Review NSG
resource "azurerm_network_security_rule" "master_ingress_heapster" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_heapster"
  priority               = 585
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "4194"

  # TODO: Need to allow traffic from self
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

# TODO: Review NSG
resource "azurerm_network_security_rule" "master_ingress_heapster_from_worker" {
  count                  = "${var.create_master_nsg_rules ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-master_ingress_heapster_from_worker"
  priority               = 590
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "4194"

  # TODO: Need to allow traffic from worker
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_master_nsg_name == "" ? join("",azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}
