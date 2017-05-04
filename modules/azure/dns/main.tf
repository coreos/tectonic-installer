resource "azurerm_dns_zone" "tectonic_azure_dns_zone" {
  name                = "${var.base_domain}"
  resource_group_name = "${var.resource_group_name}"
  count               = "${var.use_custom_fqdn == "true" ? 1 : 0}"
}
