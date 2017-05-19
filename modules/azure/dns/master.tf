data "null_data_source" "consts" {
  inputs = {
    use_cname = "${lower(var.public_ip_type) == "dynamic" ? 1 : 0}"
    zone_name = "${var.external_dns_zone ? var.base_domain : join("", azurerm_dns_zone.tectonic_azure_dns_zone.*.name)}"
  }
}
resource "azurerm_dns_a_record" "tectonic-api" {
  resource_group_name = "${var.resource_group_name}"
  zone_name           = "${data.null_data_source.consts.outputs.zone_name}"

  name    = "${var.cluster_name}-k8s"
  ttl     = "60"
  records = ["${var.master_ip_address}"]

  count = "${data.null_data_source.consts.outputs.use_cname ? 0 : 1}"
}

resource "azurerm_dns_cname_record" "tectonic-api" {
  resource_group_name = "${var.resource_group_name}"
  zone_name           = "${data.null_data_source.consts.outputs.zone_name}"

  name   = "${var.cluster_name}-k8s"
  ttl    = "60"
  record = "${var.master_azure_fqdn}"

  count = "${data.null_data_source.consts.outputs.use_cname ? 1 : 0}"
}

resource "azurerm_dns_a_record" "tectonic-console" {
  resource_group_name = "${var.resource_group_name}"
  zone_name           = "${data.null_data_source.consts.outputs.zone_name}"

  name    = "${var.cluster_name}"
  ttl     = "60"
  records = ["${var.console_ip_address}"]

  count = "${data.null_data_source.consts.outputs.use_cname ? 0 : 1}"
}

resource "azurerm_dns_cname_record" "tectonic-console" {
  resource_group_name = "${var.resource_group_name}"
  zone_name           = "${data.null_data_source.consts.outputs.zone_name}"

  name   = "${var.cluster_name}"
  ttl    = "60"
  record = "${var.console_azure_fqdn}"

  count = "${data.null_data_source.consts.outputs.use_cname ? 1 : 0}"
}
