resource "azurerm_network_security_group" "worker" {
  name                = "${var.tectonic_cluster_name}-worker-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "worker_egress" {
  name                        = "${var.tectonic_cluster_name}-worker_egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_ssh" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_ssh"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "22"
  destination_port_range      = "22"
  source_address_prefix       = "TODO_ssh_network"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_services" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_services"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "30000-32767"
  destination_port_range      = "30000-32767"
  # TODO: Need to allow traffic from self
  source_address_prefix       = "TODO_worker_network"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_services_from_console" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_services_from_console"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "30000-32767"
  destination_port_range      = "30000-32767"
  # TODO: Need to allow traffic from console
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_flannel" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_flannel"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "4789"
  destination_port_range      = "4789"
  # TODO: Need to allow traffic from self
  source_address_prefix       = "TODO_worker_network"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_flannel_from_master" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_flannel_from_master"
  priority                    = 600
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "4789"
  destination_port_range      = "4789"
  # TODO: Need to allow traffic from master
  source_address_prefix       = "TODO_master_network"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_kubelet_insecure" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_kubelet_insecure"
  priority                    = 700
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "10250"
  destination_port_range      = "10250"
  # TODO: Need to allow traffic from self
  source_address_prefix       = "TODO_worker_network"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_kubelet_insecure_from_master" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_kubelet_insecure_from_master"
  priority                    = 800
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "10250"
  destination_port_range      = "10250"
  # TODO: Need to allow traffic from master
  source_address_prefix       = "TODO_master_network"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_kubelet_secure" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_kubelet_secure"
  priority                    = 900
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "10255"
  destination_port_range      = "10255"
  # TODO: Need to allow traffic from self
  source_address_prefix       = "TODO_worker_network"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_kubelet_secure_from_master" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_kubelet_secure_from_master"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "10255"
  destination_port_range      = "10255"
  # TODO: Need to allow traffic from master
  source_address_prefix       = "TODO_master_network"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_node_exporter" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_node_exporter"
  priority                    = 1100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "9100"
  destination_port_range      = "9100"
  # TODO: Need to allow traffic from self
  source_address_prefix       = "TODO_worker_network"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_node_exporter_from_master" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_node_exporter_from_master"
  priority                    = 1200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "9100"
  destination_port_range      = "9100"
  # TODO: Need to allow traffic from master
  source_address_prefix       = "TODO_master_network"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_heapster" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_heapster"
  priority                    = 1300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "4194"
  destination_port_range      = "4194"
  # TODO: Need to allow traffic from self
  source_address_prefix       = "TODO_worker_network"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker_ingress_heapster_from_master" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_heapster_from_master"
  priority                    = 1400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "4194"
  destination_port_range      = "4194"
  # TODO: Need to allow traffic from master
  source_address_prefix       = "TODO_master_network"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

# TODO: Add rules for self-hosted etcd (etcd-operator)

# TODO: Review NSG
resource "azurerm_network_security_rule" "worker_ingress_http" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_http"
  priority                    = 1700
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "80"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

# TODO: Review NSG
resource "azurerm_network_security_rule" "worker_ingress_https" {
  name                        = "${var.tectonic_cluster_name}-worker_ingress_https"
  priority                    = 1800
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "443"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}
