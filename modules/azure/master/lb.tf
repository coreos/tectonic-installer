resource "azurerm_lb" "tectonic_lb" {
  name                = "api-lb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name = "api"

    subnet_id                     = "${var.subnet}"
    private_ip_address_allocation = "dynamic"
  }

  frontend_ip_configuration {
    name = "console"

    subnet_id                     = "${var.subnet}"
    private_ip_address_allocation = "dynamic"
  }
}



data "template_file" "scripts_nsupdate" {

  template = <<EOF
server 10.255.0.27
update delete dev-k8s-lb.cdx.vpc.starbucks.net A
update add dev-k8s-lb.cdx.vpc.starbucks.net 0 A $${static_ip_address}
send
EOF

  vars {
    static_ip_address = "${azurerm_lb.tectonic_lb.frontend_ip_configuration.0.private_ip_address}"
  }

}

resource "local_file" "nsupdate" {
  content  = "${data.template_file.scripts_nsupdate.rendered}"
  filename = "${path.cwd}/generated/proxy/nsupdate.txt"
}

#resource "null_resource" "scripts_nsupdate" {
#  depends_on = ["local_file.nsupdate"]

#  triggers {
#      md5 = "${md5(data.template_file.scripts_nsupdate.rendered)}"
#  }

#  provisioner "local-exec" {
#    command = "nsupdate -d ${path.cwd}/generated/proxy/nsupdate.txt"
#  }

#}