output "vnet_id" {
  value = "${var.external_vnet_name == "" ? join("",azurerm_virtual_network.tectonic_vnet.*.name) : var.external_vnet_name }"
}

output "security_group" {
  value = "${var.tectonic_cluster_name}"
}

output "security_group_id" {
  value = "${azurerm_network_security_group.cluster_default.id}"
}

# We have to do this join() & split() 'trick' because null_data_source and
# the ternary operator can't output lists or maps
#
output "master_subnet" {
  value = "${var.external_vnet_name == "" ?  join(" ", azurerm_subnet.master_subnet.*.id) : var.external_master_subnet_id }"
}

output "master_subnet_name" {
  value = "${var.tectonic_cluster_name}_master_subnet"
}

output "worker_subnet" {
  value = "${var.external_vnet_name == "" ?  join(" ", azurerm_subnet.worker_subnet.*.id) : var.external_worker_subnet_id }"
}

output "worker_subnet_name" {
  value = "${var.tectonic_cluster_name}_worker_subnet"
}

output "route_table_name" {
  value = "${azurerm_route_table.tectonic.name}"
}
