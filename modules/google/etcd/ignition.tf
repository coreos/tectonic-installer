/*
data "ignition_config" "etcd" {
  systemd = [
    "${data.ignition_systemd_unit.locksmithd.id}",
    "${data.ignition_systemd_unit.etcd3.id}",
  ]

  files = [
    "${data.ignition_file.node_hostname.id}",
  ]
}

data "ignition_file" "node_hostname" {
  path       = "/etc/hostname"
  mode       = 0644
  filesystem = "root"

  content {
    content = "${var.cluster_name}-etcd.${var.base_domain}"
  }
}

data "ignition_systemd_unit" "locksmithd" {
  name   = "locksmithd.service"
  enable = true

  dropin = [
    {
      name    = "40-etcd-lock.conf"
      content = "[Service]\nEnvironment=REBOOT_STRATEGY=etcd-lock\n"
    },
  ]
}

data "ignition_systemd_unit" "etcd3" {
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
  --advertise-client-urls=http://${var.cluster_name}-etcd.${var.base_domain}:2379 \
  --initial-advertise-peer-urls=http://${var.cluster_name}-etcd.${var.base_domain}:2380 \
  --listen-client-urls=http://0.0.0.0:2379 \
  --listen-peer-urls=http://0.0.0.0:2380
EOF
    },
  ]
}
*/
