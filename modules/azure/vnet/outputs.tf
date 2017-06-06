output "vnet_id" {
  value = "${var.external_vnet_name == "" ? join("",azurerm_virtual_network.tectonic_vnet.*.name) : var.external_vnet_name }"
}

output "master_subnet" {
  value = "${var.external_vnet_name == "" ?  join(" ", azurerm_subnet.master_subnet.*.id) : var.external_master_subnet_id }"
}

output "worker_subnet" {
  value = "${var.external_vnet_name == "" ?  join(" ", azurerm_subnet.worker_subnet.*.id) : var.external_worker_subnet_id }"
}

# TODO: Allow user to provide their own network
output "etcd_cidr" {
  value = "${azurerm_subnet.master_subnet.address_prefix}"
}

# TODO: Allow user to provide their own network
output "master_cidr" {
  value = "${azurerm_subnet.master_subnet.address_prefix}"
}

# TODO: Allow user to provide their own network
output "worker_cidr" {
  value = "${azurerm_subnet.worker_subnet.address_prefix}"
}

output "etcd_nsg_name" {
  value = "${var.external_etcd_nsg_name == "" ? join(" ", azurerm_network_security_group.etcd.*.name) : var.external_etcd_nsg_name }"
}

# TODO: Allow user to provide their own network
output "master_nsg_name" {
  value = "${var.external_master_nsg_name == "" ? join(" ", azurerm_network_security_group.master.*.name) : var.external_master_nsg_name }"
}

# TODO: Allow user to provide their own network
output "worker_nsg_name" {
  value = "${var.external_worker_nsg_name == "" ? join(" ", azurerm_network_security_group.worker.*.name) : var.external_worker_nsg_name }"
}
