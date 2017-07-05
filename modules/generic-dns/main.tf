provider "dns" {
  update {
    server        = "${var.external_dns_server}"
    key_name      = "${var.base_domain}."
    key_algorithm = "hmac-md5"
    key_secret    = "${var.external_dns_server_secret}"
  }
}

resource "dns_a_record_set" "masters" {
  count = "${var.master_count}"
  zone  = "${var.base_domain}."
  name  = "${var.cluster_name}-master-${count.index}"

  addresses = ["${var.master_ip_addresses[count.index]}"]

  ttl = 300
}

resource "dns_a_record_set" "workers" {
  count = "${var.worker_count}"
  zone  = "${var.base_domain}."
  name  = "${var.cluster_name}-worker-${count.index}"

  addresses = ["${var.worker_ip_addresses[count.index]}"]

  ttl = 300
}

resource "dns_a_record_set" "etcd" {
  count = "${var.etcd_count}"
  zone  = "${var.base_domain}."
  name  = "${var.cluster_name}-etcd-${count.index}"

  addresses = ["${var.etcd_ip_addresses[count.index]}"]

  ttl = 300
}
