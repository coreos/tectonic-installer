resource "azurerm_dns_zone" "tectonic_azure_dns_zone" {
  count               = "${var.base_domain != "" && ! var.external_dns_zone ? 1 : 0}"
  name                = "${var.base_domain}"
  resource_group_name = "${var.resource_group_name}"
}
