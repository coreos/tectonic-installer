resource "openstack_dns_zone_v2" "tectonic" {
  count = "${var.designate_dns_enabled ? 1 : 0}"
  name  = "${var.base_domain}"
}

resource "openstack_dns_recordset_v2" "tectonic-api" {
  count   = "${var.designate_dns_enabled ? 1 : 0}"
  zone_id = "${openstack_dns_zone_v2.tectonic.id}"
  name    = "${var.cluster_name}-k8s"
  type    = "A"
  ttl     = "60"
  records = ["${var.master_ips}"]
}

resource "openstack_dns_recordset_v2" "tectonic-console" {
  count   = "${var.designate_dns_enabled ? 1 : 0}"
  zone_id = "${openstack_dns_zone_v2.tectonic.id}"
  name    = "${var.cluster_name}"
  type    = "A"
  ttl     = "60"
  records = ["${var.worker_ips}"]
}
