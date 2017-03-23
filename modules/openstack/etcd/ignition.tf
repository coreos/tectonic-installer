resource "ignition_systemd_unit" "etcd2" {
  name   = "etcd2.service"
  enable = false
}

resource "ignition_systemd_unit" "etcd" {
  name   = "etcd.service"
  enable = false
}

resource "ignition_systemd_unit" "etcd_member" {
  name = "etcd-member.service"

  dropin {
    name = "40-etcd-cluster.conf"

    content = <<EOF
[Unit]
Requires=coreos-metadata.service
After=coreos-metadata.service

[Service]
EnvironmentFile=/run/metadata/coreos
Environment="ETCD_IMAGE_TAG=v3.1.0"
ExecStart=
ExecStart=/usr/lib/coreos/etcd-wrapper \
--name=etcd \
--advertise-client-urls=http://$${COREOS_OPENSTACK_IPV4_LOCAL}:2379 \
--initial-advertise-peer-urls=http://$${COREOS_OPENSTACK_IPV4_LOCAL}:2380 \
--listen-client-urls=http://0.0.0.0:2379 \
--listen-peer-urls=http://0.0.0.0:2380 \
--initial-cluster=etcd=http://$${COREOS_OPENSTACK_IPV4_LOCAL}:2380
EOF
  }
}

resource "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = ["${var.core_public_keys}"]
}

resource "ignition_config" "etcd" {
  users = [
    "${ignition_user.core.id}",
  ]

  systemd = [
    "${ignition_systemd_unit.etcd2.id}",
    "${ignition_systemd_unit.etcd.id}",
    "${ignition_systemd_unit.etcd_member.id}",
  ]
}
