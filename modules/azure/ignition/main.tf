data "azurerm_client_config" "current" {}

data "ignition_config" "main" {
  files = [
    "${data.ignition_file.kubeconfig.id}",
    "${data.ignition_file.kubelet-env.id}",
    "${data.ignition_file.max-user-watches.id}",
    "${data.ignition_file.cloud-provider.id}",
  ]

  systemd = [
    "${data.ignition_systemd_unit.docker.id}",
    "${data.ignition_systemd_unit.locksmithd.id}",
    "${data.ignition_systemd_unit.kubelet.id}",
    "${data.ignition_systemd_unit.bootkube.id}",
    "${data.ignition_systemd_unit.tectonic.id}",
  ]

  users = [
    "${data.ignition_user.core.id}",
  ]
}

# TODO: Is this actually needed since required virtual_machine config creates
# a core user and seeds the ssh key
data "ignition_user" "core" {
  name = "core"

  ssh_authorized_keys = [
    "${file(var.public_ssh_key)}",
  ]
}

data "ignition_systemd_unit" "docker" {
  name   = "docker.service"
  enable = true

  dropin = [
    {
      name    = "10-dockeropts.conf"
      content = "[Service]\nEnvironment=\"DOCKER_OPTS=--log-opt max-size=50m --log-opt max-file=3\"\n"
    },
  ]
}

data "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"
  mask = true
}

data "template_file" "kubelet" {
  template = "${file("${path.module}/resources/kubelet.service")}"

  vars {
    cluster_dns       = "${var.kube_dns_service_ip}"
    node_label        = "${var.kubelet_node_label}"
    node_taints_param = "${var.kubelet_node_taints != "" ? "--register-with-taints=${var.kubelet_node_taints}" : ""}"
  }
}

data "ignition_systemd_unit" "kubelet" {
  name    = "kubelet.service"
  enable  = true
  content = "${data.template_file.kubelet.rendered}"
}

data "ignition_file" "kubeconfig" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubeconfig"
  mode       = "420"

  content {
    content = "${var.kubeconfig_content}"
  }
}

data "ignition_file" "kubelet-env" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubelet.env"
  mode       = "420"

  content {
    content = <<EOF
KUBELET_IMAGE_URL="${var.kube_image_url}"
KUBELET_IMAGE_TAG="${var.kube_image_tag}"
EOF
  }
}

data "template_file" "cloud-provider" {
  template = "${file("${path.module}/resources/cloud-provider.json")}"

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

data "ignition_file" "cloud-provider" {
  filesystem = "root"
  path       = "/etc/kubernetes/azure.json"
  mode       = "420"
  content {
    content = "${data.template_file.cloud-provider.rendered}"
  }
}

data "ignition_file" "max-user-watches" {
  filesystem = "root"
  path       = "/etc/sysctl.d/max-user-watches.conf"
  mode       = "420"

  content {
    content = "fs.inotify.max_user_watches=16184"
  }
}

data "ignition_systemd_unit" "bootkube" {
  name    = "bootkube.service"
  content = "${var.bootkube_service}"
}

data "ignition_systemd_unit" "tectonic" {
  name    = "tectonic.service"
  enable  = "${var.tectonic_service_disabled == 0 ? true : false}"
  content = "${var.tectonic_service}"
}
