resource "aws_route53_record" "worker_nodes" {
  count   = "${var.route53_dns_enabled ? var.worker_count : 0}"
  zone_id = "${aws_route53_zone.tectonic.zone_id}"
  name    = "${var.cluster_name}-worker-${count.index}"
  type    = "A"
  ttl     = "60"
  records = ["${var.worker_ips[count.index]}"]
}
