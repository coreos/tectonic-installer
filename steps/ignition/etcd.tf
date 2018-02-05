data "ignition_config" "etcd" {
  count = "${length(data.template_file.etcd_hostname_list.*.id)}"

  systemd = [
    "${data.ignition_systemd_unit.locksmithd.*.id[count.index]}",
    "${module.ignition_masters.etcd_dropin_id_list[count.index]}",
  ]

  files = [
    "${module.ignition_masters.etcd_crt_id_list}",
  ]
}

data "ignition_systemd_unit" "locksmithd" {
  count = "${length(data.template_file.etcd_hostname_list.*.id)}"

  name    = "locksmithd.service"
  enabled = true

  dropin = [
    {
      name = "40-etcd-lock.conf"

      content = <<EOF
[Service]
Environment=REBOOT_STRATEGY=etcd-lock
Environment=\"LOCKSMITHD_ETCD_CAFILE=/etc/ssl/etcd/ca.crt\"
Environment=\"LOCKSMITHD_ETCD_KEYFILE=/etc/ssl/etcd/client.key\"
Environment=\"LOCKSMITHD_ETCD_CERTFILE=/etc/ssl/etcd/client.crt\"
Environment="LOCKSMITHD_ENDPOINT=https://${var.tectonic_cluster_name}-etcd-${count.index}.${var.tectonic_base_domain}:2379"
EOF
    },
  ]
}

resource "aws_s3_bucket_object" "ignition_etcd" {
  count = "${length(data.template_file.etcd_hostname_list.*.id)}"

  bucket  = "${local.s3_bucket}"
  key     = "ignition_etcd_${count.index}.json"
  content = "${data.ignition_config.etcd.*.rendered[count.index]}"
  acl     = "private"

  server_side_encryption = "AES256"

  tags = "${merge(map(
      "Name", "${var.tectonic_cluster_name}-ignition-etcd-${count.index}",
      "KubernetesCluster", "${var.tectonic_cluster_name}",
      "tectonicClusterID", "${local.cluster_id}"
    ), var.tectonic_aws_extra_tags)}"
}

data "ignition_config" "s3" {
  count = "${length(data.template_file.etcd_hostname_list.*.id)}"

  replace {
    source       = "${format("s3://%s/%s", local.s3_bucket, aws_s3_bucket_object.ignition_etcd.*.key[count.index])}"
    verification = "sha512-${sha512(data.ignition_config.etcd.*.rendered[count.index])}"
  }
}
