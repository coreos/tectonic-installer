resource "azurerm_network_security_group" "master" {
  name                = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
  location            = "${var.location}"
  resource_group_name = "tectonic-cluster-${var.tectonic_cluster_name}"
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
  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
}

#resource "azurerm_network_security_rule" "master_ingress_icmp" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_icmp"
#  priority                    = 200
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "icmp"
#  source_port_range           = "*"
#  destination_port_range      = "*"
#  source_address_prefix       = "*"
#  destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

resource "azurerm_network_security_rule" "master_ingress_ssh" {
  name                        = "${var.tectonic_cluster_name}-master_ingress_ssh"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "22"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
}

resource "azurerm_network_security_rule" "master_ingress_http" {
  name                        = "${var.tectonic_cluster_name}-master_ingress_http"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "80"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
}

resource "azurerm_network_security_rule" "master_ingress_https" {
  name                        = "${var.tectonic_cluster_name}-master_ingress_https"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "443"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
}

#resource "azurerm_network_security_rule" "master_ingress_heapster" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_heapster"
#  priority                    = 600
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "4194"
#  destination_port_range      = "4194"
#  # TODO: Need to allow traffic from self
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_heapster_from_worker" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_heapster_from_worker"
#  priority                    = 700
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "4194"
#  destination_port_range      = "4194"
#  # TODO: Need to allow traffic from worker
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_flannel" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_flannel"
#  priority                    = 800
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "udp"
#  source_port_range           = "4789"
#  destination_port_range      = "4789"
#  # TODO: Need to allow traffic from self
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_flannel_from_worker" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_flannel_from_worker"
#  priority                    = 900
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "udp"
#  source_port_range           = "4789"
#  destination_port_range      = "4789"
#  # TODO: Need to allow traffic from worker
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_node_exporter" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_node_exporter"
#  priority                    = 1000
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "9100"
#  destination_port_range      = "9100"
#  # TODO: Need to allow traffic from self
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_node_exporter_from_worker" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_node_exporter_from_worker"
#  priority                    = 1100
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "9100"
#  destination_port_range      = "9100"
#  # TODO: Need to allow traffic from worker
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_kubelet_insecure" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_kubelet_insecure"
#  priority                    = 1200
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "10250"
#  destination_port_range      = "10250"
#  # TODO: Need to allow traffic from self
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_kubelet_insecure_from_worker" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_kubelet_insecure_from_worker"
#  priority                    = 1300
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "10250"
#  destination_port_range      = "10250"
#  # TODO: Need to allow traffic from worker
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_kubelet_secure" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_kubelet_secure"
#  priority                    = 1400
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "10255"
#  destination_port_range      = "10255"
#  # TODO: Need to allow traffic from self
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_kubelet_secure_from_worker" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_kubelet_secure_from_worker"
#  priority                    = 1500
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "10255"
#  destination_port_range      = "10255"
#  # TODO: Need to allow traffic from worker
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_etcd" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_etcd"
#  priority                    = 1600
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "2379"
#  destination_port_range      = "2380"
#  # TODO: Need to allow traffic from self
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_bootstrap_etcd" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_bootstrap_etcd"
#  priority                    = 1700
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "12379"
#  destination_port_range      = "12380"
#  # TODO: Need to allow traffic from self
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_services" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_services"
#  priority                    = 1800
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "32000"
#  destination_port_range      = "32767"
#  # TODO: Need to allow traffic from self
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}

#resource "azurerm_network_security_rule" "master_ingress_services_from_console" {
#  name                        = "${var.tectonic_cluster_name}-master_ingress_services_from_console"
#  priority                    = 1900
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "32000"
#  destination_port_range      = "32767"
#  # TODO: Need to allow traffic from console
#  #source_address_prefix       = "*"
#  #destination_address_prefix  = "*"
#  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
#  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
#}
