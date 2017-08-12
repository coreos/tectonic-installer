resource "azurerm_lb" "tectonic_lb" {
  count = "${var.network_implementation == "public" ? 1 : 0}"
  name                = "${var.cluster_name}-api-lb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name = "api"
    subnet_id = "${var.external_vnet_id == "" ? join(" ", azurerm_subnet.master_subnet.*.id) : var.external_master_subnet_id }"
    public_ip_address_id          = "${azurerm_public_ip.api_ip.id}"
  }

  frontend_ip_configuration {
    name = "console"
    subnet_id = "${var.external_vnet_id == "" ? join(" ", azurerm_subnet.master_subnet.*.id) : var.external_master_subnet_id }"
    public_ip_address_id          = "${azurerm_public_ip.console_ip.id}"
  }

  tags = "${merge(map(
    "Name", "${var.cluster_name}-api-lb",
    "tectonicClusterID", "${var.cluster_id}"),
    var.extra_tags)}"
}

resource "azurerm_lb" "tectonic_lb_internal" {
  count = "${var.network_implementation == "private" ? 1 : 0}"
  name                = "${var.cluster_name}-api-lb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name = "api"
    subnet_id = "${var.external_vnet_id == "" ? join(" ", azurerm_subnet.master_subnet.*.id) : var.external_master_subnet_id }"
    private_ip_address_allocation = "dynamic"
  }

  frontend_ip_configuration {
    name = "console"
    subnet_id = "${var.external_vnet_id == "" ? join(" ", azurerm_subnet.master_subnet.*.id) : var.external_master_subnet_id }"
    private_ip_address_allocation = "dynamic"
  }

  tags = "${merge(map(
    "Name", "${var.cluster_name}-api-lb",
    "tectonicClusterID", "${var.cluster_id}"),
    var.extra_tags)}"
}
