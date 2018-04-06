data "ignition_file" "etcd_ca" {
  count = "${var.etcd_count > 0 ? 1 : 0}"

  path       = "/etc/ssl/etcd/ca.crt"
  mode       = 0644
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.etcd_ca_cert_pem}"
  }
}

data "ignition_file" "etcd_client_key" {
  path       = "/etc/ssl/etcd/client.key"
  mode       = 0400
  uid        = 0
  gid        = 0
  filesystem = "root"

  content {
    content = "${var.etcd_client_key_pem}"
  }
}

data "ignition_file" "etcd_client_crt" {
  path       = "/etc/ssl/etcd/client.crt"
  mode       = 0400
  uid        = 0
  gid        = 0
  filesystem = "root"

  content {
    content = "${var.etcd_client_crt_pem}"
  }
}

data "ignition_file" "etcd_server_key" {
  count = "${var.etcd_count > 0 ? 1 : 0}"

  path       = "/etc/ssl/etcd/server.key"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.etcd_server_key_pem}"
  }
}

data "ignition_file" "etcd_server_crt" {
  count = "${var.etcd_count > 0 ? 1 : 0}"

  path       = "/etc/ssl/etcd/server.crt"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.etcd_server_crt_pem}"
  }
}

data "ignition_file" "etcd_peer_key" {
  count = "${var.etcd_count > 0 ? 1 : 0}"

  path       = "/etc/ssl/etcd/peer.key"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.etcd_peer_key_pem}"
  }
}

data "ignition_file" "etcd_peer_crt" {
  count = "${var.etcd_count > 0 ? 1 : 0}"

  path       = "/etc/ssl/etcd/peer.crt"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.etcd_peer_crt_pem}"
  }
}
