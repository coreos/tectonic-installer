resource "azurerm_network_security_group" "worker" {
  count               = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                = "${var.cluster_name}-worker"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "worker_egress" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-out"
  priority                    = 2010
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_ssh" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-ssh-internal"
  priority                    = 600
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_internal}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_ssh_admin" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-ssh-external"
  priority                    = 605
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_external}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

# TODO: Determine if we need two rules for this
resource "azurerm_network_security_rule" "worker_ingress_services" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-tcp-30000-32767-vnet1"
  priority                    = 610
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "30000-32767"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_services_from_console" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-tcp-30000-32767-vnet2"
  priority                    = 615
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "30000-32767"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_flannel" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-udp-4789-vnet"
  priority                    = 620
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "4789"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_flannel_from_master" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-udp-4789-master"
  priority                    = 625
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "4789"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_kubelet_insecure" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-tcp-10250-vnet"
  priority                    = 630
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "10250"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_kubelet_insecure_from_master" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-tcp-10250-master"
  priority                    = 635
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "10250"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_kubelet_secure" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-tcp-10255-vnet"
  priority                    = 640
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_kubelet_secure_from_master" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-tcp-10255-master"
  priority                    = 645
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_node_exporter" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-tcp-9100-vnet"
  priority                    = 650
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "9100"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_node_exporter_from_master" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-tcp-9100-master"
  priority                    = 655
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "9100"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_heapster" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-tcp-4194-vnet"
  priority                    = 660
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "4194"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_heapster_from_master" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-tcp-4194-master"
  priority                    = 665
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "4194"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_http" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-http"
  priority                    = 670
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_https" {
  count                       = "${var.external_nsg_worker_id == "" ? 1 : 0}"
  name                        = "${var.cluster_name}-worker-in-https"
  priority                    = 675
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}
