resource "azurerm_lb" "api_lb" {
  name                = "${var.cluster_name}-api-lb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                          = "api"
    public_ip_address_id          = "${azurerm_public_ip.api_ip.id}"
    private_ip_address_allocation = "dynamic"
  }

  tags = "${merge(map(
    "Name", "${var.cluster_name}-api-lb",
    "tectonicClusterID", "${var.cluster_id}"),
    var.extra_tags)}"
}

resource "azurerm_lb" "ingress_lb" {
  name                = "${var.cluster_name}-ingress-lb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                          = "tectonic-ingress"
    public_ip_address_id          = "${azurerm_public_ip.ingress_ip.id}"
    private_ip_address_allocation = "dynamic"
  }

  tags = "${merge(map(
    "Name", "${var.cluster_name}-ingress-lb",
    "tectonicClusterID", "${var.cluster_id}"),
    var.extra_tags)}"
}
