resource "aws_route53_record" "master_nodes" {
  count   = "${var.route53_dns_enabled ? var.master_count : 0 }"
  zone_id = "${aws_route53_zone.tectonic.zone_id}"
  name    = "${var.cluster_name}-master-${count.index}"
  type    = "A"
  ttl     = "60"
  records = ["${var.master_ips[count.index]}"]
}
