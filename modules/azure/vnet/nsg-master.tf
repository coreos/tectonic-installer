### LB rules
resource "azurerm_network_security_rule" "alb_probe" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-alb-probe"
  priority                    = 295
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "${var.vnet_cidr_block}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

# TODO: Fix NSG name and source
resource "azurerm_network_security_rule" "api_ingress_https" {
  count                  = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                   = "${var.cluster_name}-api-in-https"
  priority               = 300
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "443"

  # TODO: Ternary on private implementation
  source_address_prefix       = "*"
  destination_address_prefix  = "${var.vnet_cidr_block}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "console_ingress_https" {
  count                  = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                   = "${var.cluster_name}-console-in-https"
  priority               = 305
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "443"

  # TODO: Ternary on private implementation
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureLoadBalancer"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "console_ingress_http" {
  count                  = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                   = "${var.cluster_name}-console-in-http"
  priority               = 310
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "80"

  # TODO: Ternary on private implementation
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "AzureLoadBalancer"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

### Master node rules

resource "azurerm_network_security_group" "master" {
  count               = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                = "${var.cluster_name}-master"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "master_egress" {
  count                  = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                   = "${var.cluster_name}-master-out"
  priority               = 2005
  direction              = "Outbound"
  access                 = "Allow"
  protocol               = "*"
  source_port_range      = "*"
  destination_port_range = "*"

  # TODO: Reference subnet
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_ssh" {
  count                  = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                   = "${var.cluster_name}-master-in-ssh"
  priority               = 500
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "22"

  # TODO: Reference subnet
  source_address_prefix       = "${var.ssh_network_internal}"
  destination_address_prefix  = "${var.vnet_cidr_block}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_ssh_admin" {
  count                  = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                   = "${var.cluster_name}-master-in-ssh-external"
  priority               = 505
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "22"

  # TODO: Reference subnet
  source_address_prefix       = "${var.ssh_network_external}"
  destination_address_prefix  = "${var.vnet_cidr_block}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_flannel_from_master" {
  count                  = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                   = "${var.cluster_name}-master-in-udp-4789-master"
  priority               = 510
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "udp"
  source_port_range      = "*"
  destination_port_range = "4789"

  # TODO: Reference subnet
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "${var.vnet_cidr_block}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_flannel_from_worker" {
  count                  = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                   = "${var.cluster_name}-master-in-udp-4789-worker"
  priority               = 515
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "udp"
  source_port_range      = "*"
  destination_port_range = "4789"

  # TODO: Reference subnet
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "${var.vnet_cidr_block}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_node_exporter_from_master" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-tcp-9100-master"
  priority                    = 520
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "9100"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "${var.vnet_cidr_block}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_node_exporter_from_worker" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-tcp-9100-worker"
  priority                    = 525
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "9100"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "${var.vnet_cidr_block}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

# TODO: Review NSG
resource "azurerm_network_security_rule" "master_ingress_services" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-tcp-30000-32767-vnet1"
  priority                    = 530
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "30000-32767"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

# TODO: Review NSG
resource "azurerm_network_security_rule" "master_ingress_services_from_console" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-tcp-30000-32767-vnet2"
  priority                    = 535
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "30000-32767"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_secure" {
  count                  = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                   = "${var.cluster_name}-master-in-tcp-10255-vnet"
  priority               = 565
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "10255"

  # TODO: CR on how open this should be
  # TODO: Reference subnet
  source_address_prefix = "VirtualNetwork"

  destination_address_prefix  = "${var.vnet_cidr_block}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}
