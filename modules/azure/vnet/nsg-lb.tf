resource "azurerm_network_security_rule" "alb_probe" {
  name                        = "${var.tectonic_cluster_name}-alb_probe"
  priority                    = 295
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_api_nsg_name == "" ? join("",azurerm_network_security_group.api.*.name) : var.external_api_nsg_name }"
}

resource "azurerm_network_security_group" "api" {
  count               = "${var.external_api_nsg_name == "" ? 1 : 0}"
  name                = "${var.tectonic_cluster_name}-api-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "api_egress" {
  count                       = "${var.create_api_nsg_rules ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-api_egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_api_nsg_name == "" ? join("",azurerm_network_security_group.api.*.name) : var.external_api_nsg_name }"
}

resource "azurerm_network_security_rule" "api_ingress_https" {
  count                       = "${var.create_api_nsg_rules ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-api_ingress_https"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_api_nsg_name == "" ? join("",azurerm_network_security_group.api.*.name) : var.external_api_nsg_name }"
}

resource "azurerm_network_security_group" "console" {
  count               = "${var.create_api_nsg_rules ? 1 : 0}"
  name                = "${var.tectonic_cluster_name}-console-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.external_nsg_rsg_name}"
}

resource "azurerm_network_security_rule" "console_egress" {
  count                       = "${var.create_api_nsg_rules ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-console_egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_api_nsg_name == "" ?  join("",azurerm_network_security_group.console.*.name) : var.external_api_nsg_name }"
}

resource "azurerm_network_security_rule" "console_ingress_https" {
  count                       = "${var.create_api_nsg_rules ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-console_ingress_https"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_api_nsg_name == "" ?  join("",azurerm_network_security_group.console.*.name) : var.external_api_nsg_name }"
}

resource "azurerm_network_security_rule" "console_ingress_http" {
  count                       = "${var.create_api_nsg_rules ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-console_ingress_http"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_nsg_rsg_name == "" ? var.resource_group_name : var.external_nsg_rsg_name}"
  network_security_group_name = "${var.external_api_nsg_name == "" ?  join("",azurerm_network_security_group.console.*.name) : var.external_api_nsg_name }"
}
