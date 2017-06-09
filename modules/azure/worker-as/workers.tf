# TODO
# Add to availabilityset

# Generate unique storage name
resource "random_id" "tectonic_storage_name" {
  byte_length = 4
}

resource "azurerm_storage_account" "tectonic_worker" {
  name                = "${random_id.tectonic_storage_name.hex}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  account_type        = "${var.storage_account_type}"

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

# resource "azurerm_lb_backend_address_pool" "workers" {
#   name                = "workers-lb-pool"
#   resource_group_name = "${var.resource_group_name}"
#   loadbalancer_id     = "${azurerm_lb.tectonic_lb.id}"
# }

resource "azurerm_availability_set" "tectonic_workers" {
  name                = "${var.cluster_name}-workers"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_interface" "tectonic_worker" {
  count               = "${var.worker_count}"
  name                = "${var.cluster_name}-worker${count.index}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    private_ip_address_allocation = "dynamic"
    name                          = "${var.cluster_name}-WorkerIPConfiguration"
    subnet_id                     = "${var.subnet}"

    # load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.workers.id}"]
  }
}

resource "azurerm_virtual_machine" "tectonic_worker" {
  count                 = "${var.worker_count}"
  name                  = "${var.cluster_name}-worker${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${element(azurerm_network_interface.tectonic_worker.*.id, count.index)}"]
  vm_size               = "${var.vm_size}"

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "latest"
  }

  storage_os_disk {
    name          = "worker-osdisk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    os_type       = "linux"
    vhd_uri       = "${azurerm_storage_account.tectonic_worker.primary_blob_endpoint}${azurerm_storage_container.tectonic_worker.name}/${var.cluster_name}-worker${count.index}.vhd"
  }

  os_profile {
    computer_name  = "${var.cluster_name}-worker${count.index}"
    admin_username = "core"
    admin_password = ""
    custom_data    = "${base64encode("${data.ignition_config.worker.rendered}")}"
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
