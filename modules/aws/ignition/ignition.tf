data "ignition_config" "main" {
  files = [
    "${data.ignition_file.max_user_watches.id}",
    "${data.ignition_file.s3_puller.id}",
    "${data.ignition_file.init_assets.id}",
    "${data.ignition_file.detect_master.id}",
  ]

  systemd = [
    "${data.ignition_systemd_unit.docker.id}",
    "${data.ignition_systemd_unit.locksmithd.id}",
    "${data.ignition_systemd_unit.kubelet.id}",
    "${data.ignition_systemd_unit.kubelet_env.id}",
    "${data.ignition_systemd_unit.init_assets.id}",
    "${data.ignition_systemd_unit.bootkube.id}",
    "${data.ignition_systemd_unit.tectonic.id}",
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
  template = "${file("${path.module}/resources/services/kubelet.service")}"

  vars {
    cluster_dns_ip         = "${var.kube_dns_service_ip}"
    node_label             = "${var.kubelet_node_label}"
    node_taints_param      = "${var.kubelet_node_taints != "" ? "--register-with-taints=${var.kubelet_node_taints}" : ""}"
    cni_bin_dir_flag       = "${var.kubelet_cni_bin_dir != "" ? "--cni-bin-dir=${var.kubelet_cni_bin_dir}" : ""}"
    kubeconfig_s3_location = "${var.kubeconfig_s3_location}"
  }
}

data "ignition_systemd_unit" "kubelet" {
  name    = "kubelet.service"
  enable  = true
  content = "${data.template_file.kubelet.rendered}"
}

data "template_file" "kubelet_env" {
  template = "${file("${path.module}/resources/services/kubelet-env.service")}"

  vars {
    kube_version_image_url = "${replace(var.container_images["kube_version"],var.image_re,"$1")}"
    kube_version_image_tag = "${replace(var.container_images["kube_version"],var.image_re,"$2")}"
    kubelet_image_url      = "${replace(var.container_images["hyperkube"],var.image_re,"$1")}"
    kubeconfig_s3_location = "${var.kubeconfig_s3_location}"
  }
}

data "ignition_systemd_unit" "kubelet_env" {
  name    = "kubelet-env.service"
  enable  = true
  content = "${data.template_file.kubelet_env.rendered}"
}

data "ignition_file" "max_user_watches" {
  filesystem = "root"
  path       = "/etc/sysctl.d/max-user-watches.conf"
  mode       = 0644

  content {
    content = "fs.inotify.max_user_watches=16184"
  }
}

data "template_file" "s3_puller" {
  template = "${file("${path.module}/resources/s3-puller.sh")}"

  vars {
    awscli_image = "${var.container_images["awscli"]}"
  }
}

data "ignition_file" "s3_puller" {
  filesystem = "root"
  path       = "/opt/s3-puller.sh"
  mode       = 0755

  content {
    content = "${data.template_file.s3_puller.rendered}"
  }
}

data "ignition_file" "detect_master" {
  filesystem = "root"
  path       = "/opt/detect-master.sh"
  mode       = 0755

  content {
    content = "${file("${path.module}/resources/detect-master.sh")}"
  }
}

data "template_file" "init_assets" {
  template = "${file("${path.module}/resources/init-assets.sh")}"

  vars {
    cluster_name       = "${var.cluster_name}"
    awscli_image       = "${var.container_images["awscli"]}"
    assets_s3_location = "${var.assets_s3_location}"
    kubelet_image_url  = "${replace(var.container_images["hyperkube"],var.image_re,"$1")}"
    kubelet_image_tag  = "${replace(var.container_images["hyperkube"],var.image_re,"$2")}"
  }
}

data "ignition_file" "init_assets" {
  filesystem = "root"
  path       = "/opt/tectonic/init-assets.sh"
  mode       = 0755

  content {
    content = "${data.template_file.init_assets.rendered}"
  }
}

data "ignition_systemd_unit" "init_assets" {
  name    = "init-assets.service"
  enable  = "${var.assets_s3_location != "" ? true : false}"
  content = "${file("${path.module}/resources/services/init-assets.service")}"
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
