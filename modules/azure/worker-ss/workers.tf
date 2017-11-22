resource "azurerm_virtual_machine_scale_set" "tectonic_workers" {
  name                = "${var.cluster_name}-workers"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  upgrade_policy_mode = "Manual"

  # TODO: Uncomment this once support for Azure LB Standard becomes GA
  #single_placement_group = false

  sku {
    name     = "${var.vm_size}"
    capacity = "${var.worker_count}"
  }
  storage_profile_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "${var.container_linux_channel}"
    version   = "${var.container_linux_version}"
  }
  storage_profile_os_disk {
    managed_disk_type = "${var.storage_type}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    os_type           = "linux"
  }
  os_profile {
    computer_name_prefix = "${var.cluster_name}-worker-"
    admin_username       = "core"
    admin_password       = ""
    custom_data          = "${base64encode("${data.ignition_config.worker.rendered}")}"
  }
  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/core/.ssh/authorized_keys"
      key_data = "${file(var.public_ssh_key)}"
    }
  }
  network_profile {
    name    = "${var.cluster_name}-worker-ss-net-profile"
    primary = true

    ip_configuration {
      name      = "${var.cluster_name}-WorkerIPConfiguration"
      subnet_id = "${var.worker_subnet}"

      #load_balancer_backend_address_pool_ids = ["${var.worker_backend_pool}"]
    }
  }
  tags = "${merge(map(
    "Name", "${var.cluster_name}-workers",
    "tectonicClusterID", "${var.cluster_id}"),
    var.extra_tags)}"
}
