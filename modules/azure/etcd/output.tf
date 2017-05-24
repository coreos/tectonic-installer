output "ip_address" {
  value = ["${azurerm_public_ip.etcd_publicip.ip_address}"]
}

#output "lb_ip" {
#  value = "${azurerm_public_ip.etcd_publicip.ip_address}"
#}

