resource "azurerm_dns_a_record" "tectonic-api" {
  count = "${var.base_domain != "" ? 1 : 0}"

  resource_group_name = "${var.resource_group_name}"
  zone_name           = "${var.base_domain}"

  name    = "${var.cluster_name}-k8s"
  ttl     = "60"
  records = ["${var.master_ip_addresses}"]
}

resource "azurerm_dns_a_record" "tectonic-console" {
  count = "${var.base_domain != "" ? 1 : 0}"

  resource_group_name = "${var.resource_group_name}"
  zone_name           = "${var.base_domain}"

  name    = "${var.cluster_name}"
  ttl     = "60"
  records = ["${var.console_ip_address}"]
}

resource "azurerm_dns_a_record" "master_nodes" {
  count = "${var.base_domain != "" ? 1 : 0}"

  resource_group_name = "${var.resource_group_name}"
  zone_name           = "${var.base_domain}"

  name    = "${var.cluster_name}-master"
  ttl     = "59"
  records = ["${var.master_ip_addresses}"]
}
