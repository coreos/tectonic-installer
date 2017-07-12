resource "azurerm_availability_set" "etcd" {
  name                = "${var.cluster_name}-etcd"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_virtual_machine" "etcd_node" {
  count                 = "${var.etcd_count}"
  name                  = "${format("%s-%s-%03d", var.cluster_name, var.role, count.index + 1)}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${var.network_interface_ids[count.index]}"]
  vm_size               = "${var.vm_size}"
  location              = "${var.location}"
  availability_set_id   = "${azurerm_availability_set.etcd.id}"

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "latest"
  }

  storage_os_disk {
    name          = "etcd-disk"
    vhd_uri       = "${azurerm_storage_account.etcd_storage.primary_blob_endpoint}${azurerm_storage_container.etcd_storage_container.name}/etcd-disk-${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${format("%s%s%03d", var.cluster_name, "e", count.index + 1)}"
    admin_username = "core"
    admin_password = ""
    custom_data    = "${base64encode("${data.ignition_config.etcd.*.rendered[count.index]}")}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/core/.ssh/authorized_keys"
      key_data = "${file(var.public_ssh_key)}"
    }
  }
}

resource "random_id" "storage" {
  byte_length = 2
}

resource "azurerm_storage_account" "etcd_storage" {
  name                = "${var.cluster_name}${random_id.storage.hex}etcd"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  account_type        = "${var.storage_account_type}"
}

resource "azurerm_storage_container" "etcd_storage_container" {
  name                  = "${var.cluster_name}-etcd-storage-container"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_name  = "${azurerm_storage_account.etcd_storage.name}"
  container_access_type = "private"
  depends_on            = ["azurerm_storage_account.etcd_storage"]
}
