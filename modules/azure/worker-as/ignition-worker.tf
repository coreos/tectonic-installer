data "ignition_config" "worker" {
  files = [
    "${data.ignition_file.kubeconfig.id}",
    "${data.ignition_file.kubelet-env.id}",
    "${module.azure_udev-rules.udev-rules_id}",
    "${var.ign_max_user_watches_id}",
    "${data.ignition_file.cloud-provider-config.id}",
  ]

  systemd = [
    "${var.ign_docker_dropin_id}",
    "${data.ignition_systemd_unit.locksmithd.id}",
    "${data.ignition_systemd_unit.kubelet-worker.id}",
    "${module.net_ignition.tx-off_id}",
  ]

  users = [
    "${data.ignition_user.core.id}",
  ]
}

data "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"
  mask = true
}

data "template_file" "kubelet-worker" {
  template = "${file("${path.module}/resources/worker-kubelet.service")}"

  vars {
    node_label       = "${var.kubelet_node_label}"
    cloud_provider   = "${var.cloud_provider}"
    cluster_dns      = "${var.tectonic_kube_dns_service_ip}"
    cni_bin_dir_flag = "${var.kubelet_cni_bin_dir != "" ? "--cni-bin-dir=${var.kubelet_cni_bin_dir}" : ""}"
  }
}

data "ignition_systemd_unit" "kubelet-worker" {
  name    = "kubelet.service"
  enable  = true
  content = "${data.template_file.kubelet-worker.rendered}"
}

data "ignition_file" "kubeconfig" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubeconfig"
  mode       = 0644

  content {
    content = "${var.kubeconfig_content}"
  }
}

data "ignition_file" "azure_udev_rules" {
  filesystem = "root"
  path       = "/etc/udev/rules.d/66-azure-storage.rules"
  mode       = 0644

  content {
    content = "${file("${path.module}/resources/66-azure-storage.rules")}"
  }
}

data "ignition_file" "kubelet-env" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubelet.env"
  mode       = 0644

  content {
    content = <<EOF
KUBELET_IMAGE_URL="${var.kube_image_url}"
KUBELET_IMAGE_TAG="${var.kube_image_tag}"
EOF
  }
}

data "ignition_file" "cloud-provider-config" {
  filesystem = "root"
  path       = "/etc/kubernetes/cloud/config"
  mode       = 0600

  content {
    content = "${var.cloud_provider_config}"
  }
}

data "ignition_systemd_unit" "tectonic" {
  name   = "tectonic.service"
  enable = true

  content = <<EOF
[Unit]
Description=Bootstrap a Tectonic cluster
[Service]
Type=oneshot
WorkingDirectory=/opt/tectonic
ExecStart=/usr/bin/bash /opt/tectonic/bootkube.sh
ExecStart=/usr/bin/bash /opt/tectonic/tectonic.sh kubeconfig tectonic
EOF
}

data "ignition_user" "core" {
  name = "core"

  ssh_authorized_keys = [
    "${file(var.public_ssh_key)}",
  ]
}

module "net_ignition" {
  source = "../../net/ignition"
}

module "azure_udev-rules" {
  source = "../udev-rules"
}
