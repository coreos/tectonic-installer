resource "ignition_config" "etcd" {
  users = [
    "${ignition_user.core.id}",
  ]

  files = [
    "${ignition_file.hostname-etcd.*.id[count.index]}",
  ]

  systemd = [
    "${ignition_systemd_unit.etcd3.id}",
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

resource "ignition_systemd_unit" "etcd3" {
  count  = "${length(var.external_endpoints) == 0 ? var.count : 0}"
  name   = "etcd-member.service"
  enable = true

  dropin = [
    {
      name = "40-etcd-cluster.conf"

      content = <<EOF
[Service]
Environment="ETCD_IMAGE=${var.container_image}"
ExecStart=
ExecStart=/usr/lib/coreos/etcd-wrapper \
  --name=etcd \
  --discovery-srv=${var.base_domain} \
  --advertise-client-urls=http://${var.cluster_name}-etcd-${count.index}.${var.base_domain}:2379 \
  --initial-advertise-peer-urls=http://${var.cluster_name}-etcd-${count.index}.${var.base_domain}:2380 \
  --listen-client-urls=http://0.0.0.0:2379 \
  --listen-peer-urls=http://0.0.0.0:2380
EOF
    },
  ]
}

resource "ignition_file" "hostname-etcd" {
  count      = "${var.count}"
  path       = "/etc/hostname"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "${var.cluster_name}-etcd-${count.index}"
  }
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
