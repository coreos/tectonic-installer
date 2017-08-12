output "vnet_id" {
  value = "${var.external_vnet_id == "" ? join("",azurerm_virtual_network.tectonic_vnet.*.name) : var.external_vnet_id }"
}

output "master_subnet" {
  value = "${var.external_vnet_id == "" ?  join(" ", azurerm_subnet.master_subnet.*.id) : var.external_master_subnet_id }"
}

output "worker_subnet" {
  value = "${var.external_vnet_id == "" ?  join(" ", azurerm_subnet.worker_subnet.*.id) : var.external_worker_subnet_id }"
}

output "worker_subnet_name" {
  value = "${var.external_vnet_id == "" ?  join(" ", azurerm_subnet.worker_subnet.*.name) : replace(var.external_vnet_id, "${var.const_id_to_group_name_regex}", "$2") }"
}

# TODO: Allow user to provide their own network
output "etcd_cidr" {
  value = "${azurerm_subnet.master_subnet.address_prefix}"
}

output "master_cidr" {
  value = "${azurerm_subnet.master_subnet.address_prefix}"
}

output "worker_cidr" {
  value = "${azurerm_subnet.worker_subnet.address_prefix}"
}

output "etcd_nsg_name" {
  value = "${var.external_nsg_etcd_id == "" ? join(" ", azurerm_network_security_group.etcd.*.name) : replace(var.external_nsg_etcd_id, "${var.const_id_to_group_name_regex}", "$2")}"
}

# TODO: Allow user to provide their own network
output "worker_nsg_name" {
  value = "${var.external_nsg_worker_id == "" ? join(" ", azurerm_network_security_group.worker.*.name) : var.external_nsg_worker_id }"
}

output "etcd_network_interface_ids" {
  value = ["${azurerm_network_interface.etcd_nic.*.id}"]
}

output "etcd_endpoints" {
  value = "${azurerm_network_interface.etcd_nic.*.private_ip_address}"
}

# TODO: Remove hardcoded etcd values. This is a workaround for DNS + TLS.
output "etcd_node_1_ip" {
  value = "${azurerm_network_interface.etcd_nic.0.private_ip_address}"
}

# TODO: Remove hardcoded etcd values. This is a workaround for DNS + TLS.# TODO: Remove hardcoded etcd values. This is a workaround for DNS + TLS.
output "etcd_node_2_ip" {
  value = "${azurerm_network_interface.etcd_nic.1.private_ip_address}"
}

# TODO: Remove hardcoded etcd values. This is a workaround for DNS + TLS.
output "etcd_node_3_ip" {
  value = "${azurerm_network_interface.etcd_nic.2.private_ip_address}"
}

output "master_network_interface_ids" {
  value = ["${azurerm_network_interface.tectonic_master.*.id}"]
}

output "worker_network_interface_ids" {
  value = ["${azurerm_network_interface.tectonic_worker.*.id}"]
}

output "master_private_ip_addresses" {
  value = ["${azurerm_network_interface.tectonic_master.*.private_ip_address}"]
}

output "worker_private_ip_addresses" {
  value = ["${azurerm_network_interface.tectonic_worker.*.private_ip_address}"]
}

# TODO: Allow private or public LB implementation
output "api_ip_addresses" {
  # UPSTREAM
  #value = ["${azurerm_public_ip.api_ip.ip_address}"]
  value = ["${azurerm_lb.tectonic_lb.0.private_ip_address}"]
}

# TODO: Allow private or public LB implementation
output "console_ip_addresses" {
  # UPSTREAM
  #value = ["${azurerm_public_ip.console_ip.ip_address}"]
  value = ["${azurerm_lb.tectonic_lb.1.private_ip_address}"]
}

# TODO: Allow private or public LB implementation
output "api_private_ip" {
  value = "${azurerm_lb.tectonic_lb.frontend_ip_configuration.0.private_ip_address}"
}

# TODO: Allow private or public LB implementation
output "console_private_ip" {
  value = "${azurerm_lb.tectonic_lb.frontend_ip_configuration.1.private_ip_address}"
}

# TODO: Allow private or public LB implementation
output "console_proxy_private_ip" {
  value = "${azurerm_lb.proxy_lb.private_ip_address}"
}

output "ingress_fqdn" {
  value = "${var.cluster_name}.${var.base_domain}" #"${var.base_domain == "" ? azurerm_public_ip.tectonic_console_ip.fqdn : "${var.cluster_name}.${var.base_domain}"}"
}

output "api_fqdn" {
  value = "${var.cluster_name}-api.${var.base_domain}" #"${azurerm_public_ip.tectonic_api_ip.fqdn}"
}

output "api_backend_pool" {
  value = "${azurerm_lb_backend_address_pool.api-lb.id}"
}

output "console_backend_pool" {
  value = "${azurerm_lb_backend_address_pool.api-lb.id}"
}

output "console_proxy_backend_pool" {
  value = "${azurerm_lb_backend_address_pool.console-proxy-lb.id}"
}
