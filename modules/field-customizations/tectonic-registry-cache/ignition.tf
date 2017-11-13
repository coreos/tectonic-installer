data "ignition_config" "main" {
  files = ["${concat(
    "${data.ignition_file.tectonic-registry-cache-sh.*.id}",
    "${data.ignition_file.tectonic-registry-cache-env.*.id}",
  )}"]

  systemd = ["${concat(
    "${data.ignition_systemd_unit.tectonic-registry-cache.*.id}",
    "${data.ignition_systemd_unit.tectonic-registry-watcher.*.id}",
  )}"]
}

data "ignition_file" "tectonic-registry-cache-sh" {
  filesystem = "root"
  mode       = "0744"
  path       = "/opt/bin/tectonic-registry-cache.sh"
  count      = "${var.enabled ? 1 : 0}"

  content {
    content = <<EOF
#!/bin/bash -e
/usr/bin/rkt run \
--uuid-file-save=/var/run/tectonic-registry-cache.uuid \
--trust-keys-from-https \
--insecure-options="$${REGISTRY_RKT_INSECURE_OPTIONS}" \
$${REGISTRY_RKT_IMAGE_PROTOCOL}$${REGISTRY_REPO}:$${REGISTRY_TAG} \
--net=host \
--dns=host
EOF
  }
}

data "ignition_file" "tectonic-registry-cache-env" {
  filesystem = "root"
  mode       = 0644
  path       = "/etc/tectonic/tectonic-registry-cache.env"
  count      = "${var.enabled ? 1 : 0}"

  content {
    content = <<EOF
REGISTRY_RKT_INSECURE_OPTIONS=${var.rkt_insecure_options}
REGISTRY_RKT_IMAGE_PROTOCOL=${var.rkt_image_protocol}
REGISTRY_REPO=${var.image_repo}
REGISTRY_TAG=${var.image_tag}
EOF
  }
}

data "ignition_systemd_unit" "tectonic-registry-cache" {
  name    = "tectonic-registry-cache.service"
  enabled = true
  count   = "${var.enabled ? 1 : 0}"

  content = <<EOF
[Unit]
Description=Read-only cache of tectonic container images
Before=tectonic-registry-watcher.service
After=update-ca-certificates-rehash.service
[Service]
EnvironmentFile=/etc/tectonic/tectonic-registry-cache.env
ExecStartPre=-/usr/bin/rkt stop --uuid-file=/var/run/tectonic-registry-cache.uuid
ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/run/tectonic-registry-cache.uuid
ExecStart=/opt/bin/tectonic-registry-cache.sh
ExecStop=-/usr/bin/rkt stop --uuid-file=/var/run/tectonic-registry-cache.uuid
ExecStopPost=-/usr/bin/rkt rm --uuid-file=/var/run/tectonic-registry-cache.uuid
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "tectonic-registry-watcher" {
  name    = "tectonic-registry-watcher.service"
  enabled = true
  count   = "${var.enabled ? 1 : 0}"

  content = <<EOF
[Unit]
Description=Check for availability of local read-only container image cache
Before=kubelet.service bootkube.service
After=tectonic-registry-cache.service
Requires=tectonic-registry-cache.service
[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/usr/bin/bash -c "while true;do curl http://localhost:5000 && exit 0; sleep 3;done"
[Install]
RequiredBy=kubelet.service bootkube.service
WantedBy=multi-user.target
EOF
}
