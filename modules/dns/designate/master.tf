resource "openstack_dns_recordset_v2" "master_nodes" {
  count   = "${var.designate_dns_enabled ? var.master_count : 0 }"
  zone_id = "${openstack_dns_zone_v2.tectonic.id}"
  name    = "${var.cluster_name}-master-${count.index}"
  type    = "A"
  ttl     = "60"
  records = ["${var.master_ips[count.index]}"]
}
