resource "azurerm_network_security_group" "api" {
  name                = "${var.tectonic_cluster_name}-api-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "api_egress" {
  name                        = "${var.tectonic_cluster_name}-api_egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${azurerm_network_security_group.api.name}"

  #depends_on                  = ["azurerm_network_security_group.api"]
}

resource "azurerm_network_security_rule" "api_ingress_https" {
  name                        = "${var.tectonic_cluster_name}-api_ingress_https"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${azurerm_network_security_group.api.name}"

  #depends_on                  = ["azurerm_network_security_group.api"]
}

resource "azurerm_network_security_group" "console" {
  name                = "${var.tectonic_cluster_name}-console-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.external_nsg_rsg_name}"

  #depends_on          = ["azurerm_resource_group.tectonic_cluster"]
}

resource "azurerm_network_security_rule" "console_egress" {
  name                        = "${var.tectonic_cluster_name}-console_egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${azurerm_network_security_group.console.name}"

  #depends_on                  = ["azurerm_network_security_group.console"]
}

resource "azurerm_network_security_rule" "console_ingress_https" {
  name                        = "${var.tectonic_cluster_name}-console_ingress_https"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${azurerm_network_security_group.console.name}"

  #depends_on                  = ["azurerm_network_security_group.console"]
}

resource "azurerm_network_security_rule" "console_ingress_http" {
  name                        = "${var.tectonic_cluster_name}-console_ingress_http"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name}"
  network_security_group_name = "${azurerm_network_security_group.console.name}"

  #depends_on                  = ["azurerm_network_security_group.console"]
}
