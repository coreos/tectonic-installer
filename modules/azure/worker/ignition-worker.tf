# resource "ignition_file" "worker_hostname" {
#   count      = "${var.worker_count}"
#   path       = "/etc/hostname"
#   mode       = 0644
#   uid        = 0
#   filesystem = "root"

#   content {
#     content = "${var.cluster_name}-worker-${count.index}"
#   }
# }

resource "ignition_file" "worker_kubeconfig" {
  path       = "/etc/kubernetes/kubeconfig"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "${var.kube_config}"
  }
}

resource "ignition_file" "worker_resolv_conf" {
  path       = "/etc/resolv.conf"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = <<EOF
search ${var.base_domain}
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
  }
}

resource "ignition_systemd_unit" "worker_locksmithd" {
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

resource "ignition_systemd_unit" "worker_etcd-member" {
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
      --endpoints=${var.cluster_name}-etcd.${var.base_domain}:2379
EOF
  }
}

resource "ignition_systemd_unit" "worker_kubelet" {
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

resource "ignition_config" "worker" {
  count = "${var.worker_count}"

  users = [
    "${ignition_user.core.id}",
  ]

  files = [
    # "${ignition_file.worker_hostname.*.id[count.index]}",
    "${ignition_file.worker_kubeconfig.id}",

    "${ignition_file.worker_resolv_conf.id}",
  ]

  systemd = [
    "${ignition_systemd_unit.worker_locksmithd.id}",
    "${ignition_systemd_unit.worker_etcd-member.id}",
    "${ignition_systemd_unit.worker_kubelet.id}",
  ]
}

resource "ignition_user" "core" {
  name = "core"

  ssh_authorized_keys = [
    "${file(var.public_ssh_key)}",
  ]
}
