resource "azurerm_network_interface" "tectonic_master" {
  count               = "${var.master_count}"
  name                = "${format("%s-%s-%03d", var.cluster_name, "master", count.index + 1)}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    private_ip_address_allocation           = "dynamic"
    name                                    = "${var.cluster_name}-MasterIPConfiguration"
    subnet_id                               = "${var.external_master_subnet_id == "" ? join("",azurerm_subnet.master_subnet.*.id) : var.external_master_subnet_id}"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.api-lb.id}"]
  }
}
