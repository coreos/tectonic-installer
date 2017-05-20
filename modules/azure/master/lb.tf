resource "azurerm_lb" "tectonic_lb" {
  name                = "api-lb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name = "api"

    subnet_id                     = "${var.subnet}"
    private_ip_address_allocation = "dynamic"
  }

  frontend_ip_configuration {
    name = "console"

    subnet_id                     = "${var.subnet}"
    private_ip_address_allocation = "dynamic"
  }
}
