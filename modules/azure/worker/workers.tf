# Generate unique storage name
resource "random_id" "tectonic_storage_name" {
  byte_length = 4
}

resource "azurerm_storage_account" "tectonic_worker" {
  name                = "${random_id.tectonic_storage_name.hex}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  account_type        = "Premium_LRS"

  tags {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "tectonic_worker" {
  name                  = "vhd"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_name  = "${azurerm_storage_account.tectonic_worker.name}"
  container_access_type = "private"
}

resource "azurerm_availability_set" "tectonic_worker" {
  name                = "${var.cluster_name}-worker-availability-set"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_interface" "tectonic_worker" {
  count                     = "${var.worker_count}"
  name                      = "${var.cluster_name}-worker-network-${count.index}"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group_name}"
  network_security_group_id = "${var.nsg_id}"

  ip_configuration {
    name                          = "${var.cluster_name}-worker-ip-${count.index}"
    subnet_id                     = "${var.subnet}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "tectonic_worker" {
  count                 = "${var.worker_count}"
  name                  = "${var.cluster_name}-worker-${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  availability_set_id   = "${azurerm_availability_set.tectonic_worker.id}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.tectonic_worker.*.id[count.index]}"]

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "latest"
  }

  storage_os_disk {
    name           = "worker-disk"
    caching        = "ReadWrite"
    create_option  = "FromImage"
    os_type        = "linux"
    vhd_uri        = "${azurerm_storage_account.tectonic_worker.primary_blob_endpoint}${azurerm_storage_container.tectonic_worker.name}/worker-disk-${count.index}.vhd"
  }
  delete_os_disk_on_termination = true

  os_profile {
    computer_name  = "tectonic-worker-${count.index}"
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
    environment                                 = "staging"
  }
}
