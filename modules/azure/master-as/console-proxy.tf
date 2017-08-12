## Workaround for https://github.com/coreos/tectonic-installer/issues/657
## Related to: https://github.com/Microsoft/azure-docs/blob/master/articles/load-balancer/load-balancer-internal-overview.md#limitations

# TODO: Rewrite proxy to use CL instead of RHEL
# TODO: Move to top-level Azure variable definitions
variable "proxy_vm_size" {
  type    = "string"
  default = "Standard_DS2_v2"
}

# TODO: Move to top-level Azure variable definitions
variable "proxy_count" {
  type    = "string"
  default = "1"
}

# TODO: Move to top-level Azure variable definitions
variable proxy_storage_profile_image_reference {
  type = "map"

  default = {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7.3"
    version   = "latest"
  }
}

resource "azurerm_storage_account" "proxy" {
  name                = "${replace("${var.cluster_name}", "-", "")}${var.storage_id}p"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"

  # TODO: Parameterize account type
  account_type = "Standard_LRS"

  # TODO: Add default & extra_tags map
  tags {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "proxy" {
  name                  = "${var.cluster_name}-proxy-vhd"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_name  = "${azurerm_storage_account.proxy.name}"
  container_access_type = "private"
}

data "template_file" "scripts_proxy_bootstrap" {
  template = <<EOF
#!/bin/bash

## PROXY ##
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
sudo yum install -y nginx

sudo cp /lib64/nginx/modules/ngx_stream_module.so /usr/share/nginx/modules/ngx_stream_module.so

sudo bash -c 'cat > /etc/yum.repos.d/nginx.repo << "NGINXREPO"
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
gpgcheck=0
enabled=1
NGINXREPO'

sudo yum update --exclude=WALinuxAgent* -y
sudo yum install -y nginx

sudo bash -c 'cat > nginx.conf << "NGINXCONF"
worker_processes auto;

events {
    worker_connections   10000;
}

stream {
    resolver '$${resolver}';

    map $protocol $pro_http {
        default '$${console_internal_ip_address}:80';
    }

    map $protocol $pro_https {
        default '$${console_internal_ip_address}:443';
    }

    server {
        listen 80;
        proxy_pass $pro_http;
    }

    server {
        listen 443;
        proxy_pass $pro_https;
    }
}
NGINXCONF'

sudo rm -f /etc/nginx/nginx.conf
sudo cp nginx.conf /etc/nginx/nginx.conf

sudo firewall-cmd --zone=public --add-port=443/tcp
sudo firewall-cmd --zone=public --add-port=80/tcp
setsebool -P httpd_can_network_connect 1

rm -f /var/run/nginx.pid
sudo systemctl start nginx


EOF

  vars {
    resolver                    = "${var.nameserver}"
    console_internal_ip_address = "${var.console_private_ip}"
  }
}

resource "local_file" "scripts_proxy_bootstrap" {
  content  = "${data.template_file.scripts_proxy_bootstrap.rendered}"
  filename = "${path.cwd}/generated/proxy/console-proxy-bootstrap.sh"
}

resource "null_resource" "scripts_proxy_bootstrap" {
  depends_on = ["azurerm_storage_account.proxy", "local_file.scripts_proxy_bootstrap"]

  triggers {
    md5 = "${md5(data.template_file.scripts_proxy_bootstrap.rendered)}"
  }

  provisioner "local-exec" {
    command = "az storage blob upload --container-name ${azurerm_storage_container.proxy.name} --file ${path.cwd}/generated/proxy/console-proxy-bootstrap.sh --name console-proxy-bootstrap.sh --account-name ${azurerm_storage_account.proxy.name} --account-key ${azurerm_storage_account.proxy.primary_access_key}"
  }
}

resource "azurerm_virtual_machine_scale_set" "console-proxy" {
  name                = "${var.cluster_name}-console-proxy"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  upgrade_policy_mode = "Automatic"

  sku {
    name     = "${var.proxy_vm_size}"
    tier     = "${element(split("_", var.proxy_vm_size),0)}"
    capacity = "${var.proxy_count}"
  }

  os_profile {
    computer_name_prefix = "${var.cluster_name}-proxy-"
    admin_username       = "core"
    admin_password       = ""
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/core/.ssh/authorized_keys"
      key_data = "${file(var.public_ssh_key)}"
    }
  }

  network_profile {
    name    = "${var.cluster_name}-ProxyNetworkProfile"
    primary = true

    ip_configuration {
      name                                   = "${var.cluster_name}-ProxyIPConfiguration"
      subnet_id                              = "${var.subnet_id}"
      load_balancer_backend_address_pool_ids = ["${var.console_proxy_backend_pool}"]
    }
  }

  storage_profile_os_disk {
    name              = ""
    managed_disk_type = "${var.storage_type}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    os_type           = "linux"
  }

  storage_profile_image_reference {
    publisher = "${var.proxy_storage_profile_image_reference["publisher"]}"
    offer     = "${var.proxy_storage_profile_image_reference["offer"]}"
    sku       = "${var.proxy_storage_profile_image_reference["sku"]}"
    version   = "${var.proxy_storage_profile_image_reference["version"]}"
  }

  extension {
    name                       = "${var.cluster_name}-console-proxy"
    publisher                  = "Microsoft.Azure.Extensions"
    type                       = "CustomScript"
    type_handler_version       = "2.0"
    auto_upgrade_minor_version = true

    settings = <<SETTINGS
        {
          "fileUris": [
            "${azurerm_storage_account.proxy.primary_blob_endpoint}${azurerm_storage_container.proxy.name}/console-proxy-bootstrap.sh"
          ],
          "commandToExecute": "sudo bash console-proxy-bootstrap.sh",
          "timestamp": ${substr(null_resource.scripts_proxy_bootstrap.id, 0, 9)}
        }
SETTINGS

    protected_settings = <<PSETTINGS
        {
          "storageAccountName": "${azurerm_storage_account.proxy.name}",
          "storageAccountKey": "${azurerm_storage_account.proxy.primary_access_key}"
        }
PSETTINGS
  }
}
