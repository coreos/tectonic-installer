resource "aws_route53_record" "etc_a_nodes" {
  count   = "${var.dns_enabled ? var.instance_count : 0}"
  type    = "A"
  ttl     = "60"
  zone_id = "${var.dns_zone_id}"
  name    = "etcd-${count.index}.${var.custom_dns_name}"
  records = ["${aws_instance.etcd_node.*.private_ip[count.index]}"]
}
