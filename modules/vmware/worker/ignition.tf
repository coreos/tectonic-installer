resource "ignition_config" "worker" {
  count = "${var.count}"

  users = [
    "${ignition_user.core.id}",
  ]

  files = [
    "${ignition_file.kubeconfig.id}",
    "${ignition_file.kubelet-env.id}",
    "${ignition_file.max-user-watches.id}",
    "${ignition_file.cloudprovider.id}",
    "${ignition_file.hostname-worker.*.id[count.index]}",
  ]

  systemd = [
    "${ignition_systemd_unit.etcd-member.id}",
    "${ignition_systemd_unit.docker.id}",
    "${ignition_systemd_unit.locksmithd.id}",
    "${ignition_systemd_unit.kubelet-worker.id}",
    "${ignition_systemd_unit.vmtoolsd_member.id}",
  ]

  networkd = [
  "${ignition_networkd_unit.vmnetwork.id}",
  ]
}

resource "ignition_networkd_unit" "vmnetwork" {
    count      = "${var.count}"
    name = "00-ens192.network"
    content = <<EOF
[Match]
Name=ens192
[Network]
DNS=${var.dns_server}
Address=${var.ip_address["${count.index}"]}
Gateway=${var.gateway}
UseDomains=yes
Domains=${var.base_domain}
EOF
}
resource "ignition_systemd_unit" "vmtoolsd_member" {
  name = "vmtoolsd.service"
  enable = true
  content = <<EOF
  [Unit]
  Description=VMware Tools Agent
  Documentation=http://open-vm-tools.sourceforge.net/
  ConditionVirtualization=vmware
  [Service]
  ExecStartPre=/usr/bin/ln -sfT /usr/share/oem/vmware-tools /etc/vmware-tools
  ExecStart=/usr/share/oem/bin/vmtoolsd
  TimeoutStopSec=5
EOF
}

resource "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = ["${var.core_public_keys}"]
}

resource "ignition_file" "hostname-worker" {
  count      = "${var.count}"
  path       = "/etc/hostname"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "${var.cluster_name}-worker-${count.index}"
  }
}

resource "ignition_systemd_unit" "docker" {
  name   = "docker.service"
  enable = true
}

resource "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"

  dropin = [
    {
      name    = "40-etcd-lock.conf"
      content = "[Service]\nEnvironment=REBOOT_STRATEGY=etcd-lock\n"
    },
  ]
}

data "template_file" "kubelet-worker" {
  template = "${file("${path.module}/resources/worker-kubelet.service")}"

  vars {
    cluster_dns = "${var.tectonic_kube_dns_service_ip}"
  }
}

resource "ignition_systemd_unit" "kubelet-worker" {
  name    = "kubelet.service"
  enable  = true
  content = "${data.template_file.kubelet-worker.rendered}"
}

data "template_file" "etcd-member" {
  template = "${file("${path.module}/resources/etcd-member.service")}"

  vars {
    version   = "${var.tectonic_versions["etcd"]}"
    endpoints = "${join(",", formatlist("%s:2379", var.etcd_fqdns))}"
  }
}

resource "ignition_systemd_unit" "etcd-member" {
  name   = "etcd-member.service"
  enable = true

  dropin = [
    {
      name    = "40-etcd-gateway.conf"
      content = "${data.template_file.etcd-member.rendered}"
    },
  ]
}

resource "ignition_file" "kubeconfig" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubeconfig"
  mode       = "420"

  content {
    content = "${var.kubeconfig_content}"
  }
}

resource "ignition_file" "kubelet-env" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubelet.env"
  mode       = "420"

  content {
    content = <<EOF
KUBELET_ACI=${var.kube_image_url}
KUBELET_VERSION="${var.kube_image_tag}"
EOF
  }
}

resource "ignition_file" "max-user-watches" {
  filesystem = "root"
  path       = "/etc/sysctl.d/max-user-watches.conf"
  mode       = "420"

  content {
    content = "fs.inotify.max_user_watches=16184"
  }
}

resource "ignition_file" "cloudprovider" {
  path       = "/etc/kubernetes/vsphere.conf"
  mode       = 0600
  uid        = 0
  filesystem = "root"

  content {
    content = <<EOF
[Global]
  user = "${var.vmware_username}"
  password = "${var.vmware_password}"
  server = "${var.vmware_server}"
  port = "443"
  insecure-flag = "${var.vmware_sslselfsigned}"
  datacenter = "${var.vmware_datacenter}"
  datastore = "${var.vmware_datastore}"
  working-dir = "${var.vmware_folder}"
[Disk]
  scsicontrollertype = "pvscsi"
EOF
  }
}

resource "ignition_systemd_unit" "tectonic" {
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


