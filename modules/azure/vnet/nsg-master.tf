### LB rules
resource "azurerm_network_security_rule" "alb_probe" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-any-in-tcp-any-alb"
  priority                    = 295
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.api.name}"
}

# TODO: Fix nsg name and source
resource "azurerm_network_security_rule" "api_ingress_https" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-api-in-https"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.api.name}"
}

resource "azurerm_network_security_rule" "console_ingress_https" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-console-in-https"
  priority                    = 305
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.console.name}"
}

resource "azurerm_network_security_rule" "console_ingress_http" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-console-in-http"
  priority                    = 310
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.console.name}"
}

### Master node rules

resource "azurerm_network_security_group" "master" {
  count               = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                = "${var.cluster_name}-master"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "master_egress" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-out"
  priority                    = 2005
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_ssh" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-ssh-internal"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_internal}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_ssh_admin" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-ssh-external"
  priority                    = 505
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_external}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_flannel" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-udp-4789-vnet"
  priority                    = 510
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "4789"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_flannel_from_worker" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-udp-4789-worker"
  priority                    = 515
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "4789"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_node_exporter" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-tcp-9100-vnet"
  priority                    = 520
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "9100"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
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
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

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

resource "azurerm_network_security_rule" "master_ingress_etcd_self" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-etcd-vnet"
  priority                    = 545
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "2379-2380"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_bootstrap_etcd" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-tcp-12379-12380-vnet"
  priority                    = 550
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "12379-12380"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_insecure" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-tcp-10255-vnet"
  priority                    = 555
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "10250"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_insecure_from_worker" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-tcp-10250-worker"
  priority                    = 560
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "10250"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_secure" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-tcp-10255-vnet"
  priority                    = 565
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_kubelet_secure_from_worker" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-tcp-10255-worker"
  priority                    = 570
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_http" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-http"
  priority                    = 575
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_https" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-https"
  priority                    = 580
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_heapster" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-tcp-4194-vnet"
  priority                    = 585
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "4194"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master_ingress_heapster_from_worker" {
  count                       = "${var.external_nsg_master_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-master-in-tcp-4194-worker"
  priority                    = 590
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "4194"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}
