resource "ignition_file" "bootkube_dir" {
  path       = "/opt/bootkube/.empty"
  mode       = 0420
  uid        = 0
  filesystem = "root"

  content {
    content = ""
  }
}

resource "ignition_file" "kubelet_env" {
  path       = "/etc/kubernetes/kubelet.env"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "KUBELET_IMAGE_URL=${var.kube_image_url} KUBELET_IMAGE_TAG=${var.kube_image_tag}"
  }
}

resource "ignition_file" "kubeconfig" {
  path       = "/etc/kubernetes/kubeconfig"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "${var.kubeconfig_content}"
  }
}

resource "ignition_file" "max_user_watches_conf" {
  path       = "/etc/sysctl.d/max-user-watches.conf"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "fs.inotify.max_user_watches=16184"
  }
}

resource "ignition_file" "resolv_conf" {
  path       = "/etc/resolv.conf"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "${var.resolv_conf_content}"
  }
}

resource "ignition_file" "hostname" {
  count      = "${var.count}"
  path       = "/etc/hostname"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "${var.cluster_name}-master-${count.index}"
  }
}

resource "ignition_systemd_unit" "locksmithd" {
  name   = "locksmithd.service"
  enable = false

  dropin {
    name = "40-etcd-lock.conf"

    content = <<EOF
[Service]
Environment="REBOOT_STRATEGY=off"
Environment="LOCKSMITHCTL_ENDPOINT=http://localhost:2379"
EOF
  }
}

resource "ignition_systemd_unit" "etcd-member" {
  name = "etcd-member.service"

  dropin {
    name = "40-etcd-gateway.conf"

    content = <<EOF
[Service]
Type=simple
Environment="ETCD_IMAGE_TAG=v3.1.0"
ExecStart=
ExecStart=/usr/lib/coreos/etcd-wrapper gateway start \
      --listen-addr=127.0.0.1:2379 \
      --endpoints=${join(",", formatlist("%s:2379", var.etcd_fqdns))}
EOF
  }
}

resource "ignition_systemd_unit" "bootkube" {
  name   = "bootkube.service"
  enable = false

  content = <<EOF
[Unit]
Description=Bootstrap a Kubernetes control plane with a temp api-server

[Service]
Type=oneshot
WorkingDirectory=/opt/bootkube
ExecStartPre=-chmod a+x /opt/bootkube/assets/bootkube-start
ExecStart=/opt/bootkube/assets/bootkube-start
EOF
}

resource "ignition_systemd_unit" "kubelet" {
  name   = "kubelet.service"
  enable = true

  content = <<EOF
[Unit]
Description=Kubelet via Hyperkube ACI

[Service]
Environment="RKT_RUN_ARGS=--uuid-file-save=/var/run/kubelet-pod.uuid \
  --volume=resolv,kind=host,source=/etc/resolv.conf \
  --mount volume=resolv,target=/etc/resolv.conf \
  --volume var-lib-cni,kind=host,source=/var/lib/cni \
  --mount volume=var-lib-cni,target=/var/lib/cni \
  --volume var-log,kind=host,source=/var/log \
  --mount volume=var-log,target=/var/log"
Environment="KUBELET_IMAGE_URL=${var.kube_image_url}" "KUBELET_IMAGE_TAG=${var.kube_image_tag}"
ExecStartPre=/bin/mkdir -p /etc/kubernetes/manifests
ExecStartPre=/bin/mkdir -p /srv/kubernetes/manifests
ExecStartPre=/bin/mkdir -p /etc/kubernetes/checkpoint-secrets
ExecStartPre=/bin/mkdir -p /etc/kubernetes/cni/net.d
ExecStartPre=/bin/mkdir -p /var/lib/cni
ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/run/kubelet-pod.uuid
ExecStart=/usr/lib/coreos/kubelet-wrapper \
  --kubeconfig=/etc/kubernetes/kubeconfig \
  --require-kubeconfig \
  --cni-conf-dir=/etc/kubernetes/cni/net.d \
  --network-plugin=cni \
  --lock-file=/var/run/lock/kubelet.lock \
  --exit-on-lock-contention \
  --pod-manifest-path=/etc/kubernetes/manifests \
  --allow-privileged=true \
  --node-labels=master=true \
  --minimum-container-ttl-duration=6m0s \
  --cluster_dns=10.3.0.10 \
  --cluster_domain=cluster.local
ExecStop=-/usr/bin/rkt stop --uuid-file=/var/run/kubelet-pod.uuid
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

resource "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = ["${var.core_public_keys}"]
}

resource "ignition_config" "master" {
  count = "${var.count}"

  users = [
    "${ignition_user.core.id}",
  ]

  files = [
    "${ignition_file.bootkube_dir.id}",
    "${ignition_file.kubelet_env.id}",
    "${ignition_file.kubeconfig.id}",
    "${ignition_file.max_user_watches_conf.id}",
    "${ignition_file.resolv_conf.id}",
    "${ignition_file.hostname.*.id[count.index]}",
  ]

  systemd = [
    "${ignition_systemd_unit.locksmithd.id}",
    "${ignition_systemd_unit.etcd-member.id}",
    "${ignition_systemd_unit.bootkube.id}",
    "${ignition_systemd_unit.kubelet.id}",
  ]
}
