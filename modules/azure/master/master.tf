# TODO:
# Create global network tf file
# Add azurerm_route_table
# Add azurerm_network_security_group

# Generate unique storage name
resource "random_id" "tectonic_master_storage_name" {
  byte_length = 4
}

resource "azurerm_storage_account" "tectonic_master" {
  name                = "${random_id.tectonic_master_storage_name.hex}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  account_type        = "Premium_LRS"

  tags {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "tectonic_master" {
  name                  = "${var.cluster_name}-vhd-master"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_name  = "${azurerm_storage_account.tectonic_master.name}"
  container_access_type = "private"
}

resource "azurerm_availability_set" "tectonic_master" {
  name                = "${var.availability_set_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_interface" "tectonic_master" {
  count                     = "${var.master_count}"
  name                      = "${var.cluster_name}-master-network-${count.index}"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group_name}"
  network_security_group_id = "${var.nsg_id}"

  ip_configuration {
    name                                    = "${var.cluster_name}-master-ip-${count.index}"
    subnet_id                               = "${var.subnet}"
    private_ip_address_allocation           = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.api-lb.id}"]
  }
}

resource "azurerm_virtual_machine" "tectonic_master" {
  count                 = "${var.master_count}"
  name                  = "${var.cluster_name}-master-${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  availability_set_id   = "${azurerm_availability_set.tectonic_master.id}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.tectonic_master.*.id[count.index]}"]

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "latest"
  }

  storage_os_disk {
    name           = "master-disk"
    caching        = "ReadWrite"
    create_option  = "FromImage"
    os_type        = "linux"
    vhd_uri        = "${azurerm_storage_account.tectonic_master.primary_blob_endpoint}${azurerm_storage_container.tectonic_master.name}/master-disk-${count.index}.vhd"
  }
  delete_os_disk_on_termination = true

  os_profile {
    computer_name  = "tectonic-master-${count.index}"
    admin_username = "core"
    admin_password = ""

    custom_data = "${base64encode(var.custom_data)}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/core/.ssh/authorized_keys"
      key_data = "${file(var.public_ssh_key)}"
    }
  }

  tags {
    environment = "staging"
  }
}
