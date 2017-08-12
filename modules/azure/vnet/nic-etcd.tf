resource "azurerm_network_interface" "etcd_nic" {
  count               = "${var.etcd_count}"
  name                = "${format("%s-%s-%03d", var.cluster_name, "etcd", count.index + 1)}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  # TODO: Need to decide if we're going to allow this. Cause error if external NSG is already allocated as a subnet NSG
  #network_security_group_id = "${var.external_nsg_etcd_id == "" ? join(" ", azurerm_network_security_group.etcd.*.id) : var.external_nsg_etcd_id}"

  ip_configuration {
    name                          = "tectonic_etcd_configuration"
    subnet_id                     = "${var.external_master_subnet_id == "" ? join(" ", azurerm_subnet.master_subnet.*.id) : var.external_master_subnet_id }"
    private_ip_address_allocation = "dynamic"
  }
}
