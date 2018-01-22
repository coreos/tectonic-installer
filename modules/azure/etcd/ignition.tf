data "ignition_config" "etcd" {
  count = "${var.etcd_count}"

  systemd = [
    "${data.ignition_systemd_unit.locksmithd.*.id[count.index]}",
    "${var.ign_etcd_dropin_id_list[count.index]}",
  ]

  users = [
    "${data.ignition_user.core.id}",
  ]

  files = ["${compact(list(
    var.ign_profile_env_id,
    var.ign_systemd_default_env_id,
   ))}",
    "${var.ign_etcd_crt_id_list}",
  ]
}

data "ignition_user" "core" {
  count = "${var.etcd_count > 0 ? 1 : 0}"

  name = "core"

  ssh_authorized_keys = [
    "${file(var.public_ssh_key)}",
  ]
}

data "ignition_systemd_unit" "locksmithd" {
  count = "${var.etcd_count}"

  name    = "locksmithd.service"
  enabled = true

  dropin = [
    {
      name = "40-etcd-lock.conf"

      content = <<EOF
[Service]
Environment=REBOOT_STRATEGY=etcd-lock
Environment="LOCKSMITHD_ETCD_CAFILE=/etc/ssl/etcd/ca.crt"
Environment="LOCKSMITHD_ETCD_KEYFILE=/etc/ssl/etcd/client.key"
Environment="LOCKSMITHD_ETCD_CERTFILE=/etc/ssl/etcd/client.crt"
Environment="LOCKSMITHD_ENDPOINT=https://etcd-${count.index}:2379"
EOF
    },
  ]
}
