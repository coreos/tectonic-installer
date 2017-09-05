resource "azurerm_public_ip" "ingress_ip" {
  name                         = "${var.cluster_name}-ingress-ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${var.cluster_name}"

  tags = "${merge(map(
    "Name", "${var.cluster_name}",
    "tectonicClusterID", "${var.cluster_id}"),
    var.extra_tags)}"
}

resource "azurerm_lb_backend_address_pool" "ingress_lb" {
  name                = "ingress-lb-pool"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.ingress_lb.id}"
}

resource "azurerm_lb_rule" "ingress_lb_https" {
  name                    = "${var.cluster_name}-ingress-lb-rule-443-32000"
  resource_group_name     = "${var.resource_group_name}"
  loadbalancer_id         = "${azurerm_lb.ingress_lb.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.ingress_lb.id}"
  probe_id                = "${azurerm_lb_probe.ingress_lb.id}"

  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 32000
  frontend_ip_configuration_name = "tectonic-ingress"
}

resource "azurerm_lb_rule" "ingress_lb_identity" {
  name                    = "${var.cluster_name}-ingress-lb-rule-80-32001"
  resource_group_name     = "${var.resource_group_name}"
  loadbalancer_id         = "${azurerm_lb.ingress_lb.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.ingress_lb.id}"
  probe_id                = "${azurerm_lb_probe.ingress_lb.id}"

  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 32001
  frontend_ip_configuration_name = "tectonic-ingress"
}

resource "azurerm_lb_probe" "ingress_lb" {
  name                = "${var.cluster_name}-ingress-lb-probe-443-up"
  loadbalancer_id     = "${azurerm_lb.ingress_lb.id}"
  resource_group_name = "${var.resource_group_name}"
  protocol            = "tcp"
  port                = 32000
}
