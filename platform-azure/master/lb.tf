resource "azurerm_lb" "tectonic_lb" {
  name                = "k8-lb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                          = "k8s"
    public_ip_address_id          = "${azurerm_public_ip.tectonic_api_ip.id}"
    private_ip_address_allocation = "dynamic"
  }

  frontend_ip_configuration {
    name                          = "console"
    public_ip_address_id          = "${azurerm_public_ip.tectonic_console_ip.id}"
    private_ip_address_allocation = "dynamic"
  }
}
