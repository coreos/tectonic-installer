output "ip_address" {
  value = ["${azurerm_lb.tectonic_etcd_lb.frontend_ip_configuration.0.private_ip_address}"]
}
