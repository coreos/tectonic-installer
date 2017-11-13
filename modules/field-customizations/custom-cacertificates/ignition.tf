data "ignition_config" "main" {
  files = ["${concat(
    data.ignition_file.tectonic-custom-cacert.*.id,
  )}"]

  systemd = ["${concat(
    data.ignition_systemd_unit.update-ca-certificates-rehash.*.id,
  )}"]
}

data "ignition_file" "tectonic-custom-cacert" {
  count    = "${length(var.cacertificates)}"
  filesystem = "root"
  mode = 0640
  content {
    content = "${file(element(var.cacertificates,count.index))}"
  }
  path = "${format("/etc/ssl/certs/tectonic-custom-cacert-%d.pem",count.index)}"
}

data "ignition_systemd_unit" "update-ca-certificates-rehash" {
  name    = "update-ca-certificates-rehash.service"
  enabled = true
  count   = "${length(var.cacertificates) > 0 ? 1 : 0}"

  content = <<EOF
[Unit]
ConditionPathExists=/opt/tectonic/custom-cacerts
ConditionPathExists=!/opt/tectonic/custom-cacerts.done

After=init-assets.service
Requires=init-assets.service

[Service]
ExecStart=/usr/sbin/update-ca-certificates
ExecStart=/usr/bin/touch /opt/tectonic/custom-cacerts.done
Type=oneshot

[Install]
RequiredBy=kubelet.service
EOF
}
