output "endpoints" {
  value = ["${split(",", length(var.external_endpoints) == 0 ? join(",", azurerm_network_interface.etcd_nic.*.private_ip_address) : join(",", var.external_endpoints))}"]
}
