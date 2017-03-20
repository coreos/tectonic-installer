resource "azurerm_public_ip" "tectonic_api_ip" {
  name                         = "tectonic_api_ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "staging"
  }
}

resource "azurerm_lb_rule" "k8-lb" {
  name                    = "k8-lb-rule-443-443"
  resource_group_name     = "${var.resource_group_name}"
  loadbalancer_id         = "${azurerm_lb.tectonic_lb.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.k8-lb.id}"
  probe_id                = "${azurerm_lb_probe.k8-lb.id}"

  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "api"
}

resource "azurerm_lb_probe" "k8-lb" {
  name                = "k8-lb-probe-443-up"
  loadbalancer_id     = "${azurerm_lb.tectonic_lb.id}"
  resource_group_name = "${var.resource_group_name}"
  protocol            = "tcp"
  port                = 443
}

resource "azurerm_lb_backend_address_pool" "k8-lb" {
  name                = "k8-lb-pool"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.tectonic_lb.id}"
}

resource "azurerm_lb_rule" "ssh-lb" {
  name                    = "ssh-lb"
  resource_group_name     = "${var.resource_group_name}"
  loadbalancer_id         = "${azurerm_lb.tectonic_lb.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.k8-lb.id}"
  probe_id                = "${azurerm_lb_probe.ssh-lb.id}"
  load_distribution       = "SourceIP"

  protocol                       = "tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "api"
}

resource "azurerm_lb_probe" "ssh-lb" {
  name                = "ssh-lb-22-up"
  loadbalancer_id     = "${azurerm_lb.tectonic_lb.id}"
  resource_group_name = "${var.resource_group_name}"
  protocol            = "tcp"
  port                = 22
}
