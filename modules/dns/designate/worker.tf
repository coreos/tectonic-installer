resource "openstack_dns_recordset_v2" "worker_nodes" {
  count   = "${var.designate_dns_enabled ? var.worker_count : 0}"
  zone_id = "${openstack_dns_zone_v2.tectonic.id}"
  name    = "${var.cluster_name}-worker-${count.index}"
  type    = "A"
  ttl     = "60"
  records = ["${var.worker_ips[count.index]}"]
}
