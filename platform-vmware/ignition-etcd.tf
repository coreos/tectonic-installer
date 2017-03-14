resource "ignition_systemd_unit" "etcd2" {
  name = "etcd2.service"
  enable = false
}

resource "ignition_systemd_unit" "etcd" {
  name = "etcd.service"
  enable = false
}

resource "ignition_systemd_unit" "etcd_member" {
  name = "etcd-member.service"

  dropin {
    name = "40-etcd-cluster.conf"
    content = <<EOF
[Service]
Environment="ETCD_IMAGE_TAG=v3.1.0"
ExecStartPre=/usr/bin/sh -c '/usr/bin/systemctl set-environment COREOS_PRIVATE_IPV4=$$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)'
ExecStart=
ExecStart=/usr/lib/coreos/etcd-wrapper \
--name=etcd \
--advertise-client-urls=http://$${COREOS_PRIVATE_IPV4}:2379 \
--initial-advertise-peer-urls=http://$${COREOS_PRIVATE_IPV4}:2380 \
--listen-client-urls=http://0.0.0.0:2379 \
--listen-peer-urls=http://0.0.0.0:2380 \
--initial-cluster=etcd=http://$${COREOS_PRIVATE_IPV4}:2380
EOF
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

resource "ignition_config" "etcd" {
  count    = "${var.tectonic_etcd_count}"

  users = [
    "${ignition_user.core.id}",
  ]

  systemd = [
    "${ignition_systemd_unit.etcd2.id}",
    "${ignition_systemd_unit.etcd.id}",
    "${ignition_systemd_unit.vmtoolsd_member.id}",
    "${ignition_systemd_unit.etcd_member.id}",
  ]
}
