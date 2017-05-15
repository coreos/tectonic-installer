data "azurerm_client_config" "current" {}

data "template_file" "cloud-config" {
  depends_on = ["azurerm_storage_container.vhds"]

  template = "${file("${path.module}/resources/cloud-config.json")}"

  vars {
    cloud = "${var.arm_cloud}",
    tenant_id = "${data.azurerm_client_config.current.tenant_id}",
    subscription_id = "${data.azurerm_client_config.current.subscription_id}",
    aad_client_id = "${data.azurerm_client_config.current.client_id}",
    aad_client_secret = "${var.arm_client_secret}",
    resource_group_name = "${var.resource_group_name}",
    location = "${var.location}",
    subnet_name = "${var.subnet_name}",
    security_group_name = "${var.nsg_name}",
    vnet_name = "${var.virtual_network}",
    route_table_name = "${var.route_table_name}",
    primary_availability_set_name = "${var.primary_availability_set_name}"
  }
}

resource "random_id" "pv_storage_name" {
  byte_length = 4
}

resource "azurerm_storage_account" "pv" {
  name                = "${random_id.pv_storage_name.hex}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  account_type        = "Premium_LRS"

  tags {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "vhds" {
  name                  = "vhds"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_name  = "${azurerm_storage_account.pv.name}"
  container_access_type = "private"
}
