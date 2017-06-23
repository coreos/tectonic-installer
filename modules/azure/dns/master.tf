resource "azurerm_dns_a_record" "tectonic-api-ext" {
  count = "${var.base_domain != "" ? 1 : 0}"

  resource_group_name = "${var.resource_group_name}"
  zone_name           = "${azurerm_dns_zone.tectonic_azure_dns_zone.name}"

  name    = "${var.cluster_name}-k8s"
  ttl     = "60"
  records = ["${var.master_ip_addresses}"]
}

resource "azurerm_dns_a_record" "tectonic-console" {
  count = "${var.base_domain != "" ? 1 : 0}"

  resource_group_name = "${var.resource_group_name}"
  zone_name           = "${azurerm_dns_zone.tectonic_azure_dns_zone.name}"

  name    = "${var.cluster_name}"
  ttl     = "60"
  records = ["${var.console_ip_address}"]
}
