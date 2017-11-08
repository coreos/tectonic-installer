data "ignition_config" "main" {
  files = []

  systemd = ["${concat(
    data.ignition_systemd_unit.update-ca-certificates-rehash.*.id,
  )}"]
}

resource "local_file" "tectonic-custom-cacert" {
  count    = "${length(var.cacertificates)}"
  content  = "${file(element(var.cacertificates,count.index))}"
  filename = "${format("./generated/custom-cacerts/tectonic-custom-cacert-%d.pem",count.index)}"
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
ExecStart=/usr/bin/cp -f /opt/tectonic/custom-cacerts/tectonic-custom-cacert-*.pem /etc/ssl/certs/
ExecStart=/usr/bin/chmod 0640 /etc/ssl/certs/tectonic-custom-cacert-*.pem
ExecStart=/usr/sbin/update-ca-certificates
ExecStart=/usr/bin/touch /opt/tectonic/custom-cacerts.done
Type=oneshot

[Install]
RequiredBy=kubelet.service

EOF
}
