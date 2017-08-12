## Workaround for https://github.com/coreos/tectonic-installer/issues/657
## Related to: https://github.com/Microsoft/azure-docs/blob/master/articles/load-balancer/load-balancer-internal-overview.md#limitations

resource "azurerm_lb" "proxy_lb" {
  count = "${var.network_implementation == "private" ? 1 : 0}"
  name                = "${var.cluster_name}-console-proxy-lb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                          = "console-proxy"
    subnet_id                     = "${var.external_vnet_id == "" ? join(" ", azurerm_subnet.master_subnet.*.id) : var.external_master_subnet_id }"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "console-proxy-lb" {
  count = "${var.network_implementation == "private" ? 1 : 0}"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.proxy_lb.id}"
  name                = "console-proxy-lb-pool"
}

resource "azurerm_lb_rule" "console-proxy-lb-https" {
  count = "${var.network_implementation == "private" ? 1 : 0}"
  name                    = "console-proxy-lb-rule-443-443"
  resource_group_name     = "${var.resource_group_name}"
  loadbalancer_id         = "${azurerm_lb.proxy_lb.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.console-proxy-lb.id}"
  probe_id                = "${azurerm_lb_probe.console-proxy-lb-https.id}"

  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "console-proxy"
}

resource "azurerm_lb_probe" "console-proxy-lb-https" {
  count = "${var.network_implementation == "private" ? 1 : 0}"
  name                = "console-proxy-lb-probe-443-up"
  loadbalancer_id     = "${azurerm_lb.proxy_lb.id}"
  resource_group_name = "${var.resource_group_name}"
  protocol            = "tcp"
  port                = 443
}

resource "azurerm_lb_rule" "console-proxy-lb-http" {
  count = "${var.network_implementation == "private" ? 1 : 0}"
  name                    = "console-proxy-lb-rule-80-80"
  resource_group_name     = "${var.resource_group_name}"
  loadbalancer_id         = "${azurerm_lb.proxy_lb.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.console-proxy-lb.id}"
  probe_id                = "${azurerm_lb_probe.console-proxy-lb-http.id}"

  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "console-proxy"
}

resource "azurerm_lb_probe" "console-proxy-lb-http" {
  count = "${var.network_implementation == "private" ? 1 : 0}"
  name                = "console-proxy-lb-probe-80-up"
  loadbalancer_id     = "${azurerm_lb.proxy_lb.id}"
  resource_group_name = "${var.resource_group_name}"
  protocol            = "tcp"
  port                = 80
}
