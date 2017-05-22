output "ip_address" {
  value = ["${azurerm_lb.tectonic_lb.frontend_ip_configuration.0.private_ip_address}"]
}

output "console_ip_address" {
  value = "${azurerm_lb.tectonic_lb.frontend_ip_configuration.1.private_ip_address}"
}

output "ingress_external_fqdn" {
  value = "${azurerm_lb.tectonic_lb.frontend_ip_configuration.1.private_ip_address}"
}

output "ingress_internal_fqdn" {
  value = "${azurerm_lb.tectonic_lb.frontend_ip_configuration.1.private_ip_address}"
}

output "api_external_fqdn" {
  value = "${azurerm_lb.proxy_lb.frontend_ip_configuration.0.private_ip_address}"
}

output "api_internal_fqdn" {
  value = "${azurerm_lb.proxy_lb.frontend_ip_configuration.0.private_ip_address}"
}
