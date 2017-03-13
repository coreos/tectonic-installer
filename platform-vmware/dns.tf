data "aws_route53_zone" "tectonic" {
  name = "${var.tectonic_base_domain}"
}

resource "aws_route53_record" "tectonic-api" {
  zone_id = "${data.aws_route53_zone.tectonic.zone_id}"
  name    = "${var.tectonic_cluster_name}-k8s"
  type    = "A"
  ttl     = "60"
  records = ["${vsphere_virtual_machine.master-vm.*.network_interface.0.ipv4_address}"]
}

resource "aws_route53_record" "tectonic-console" {
  zone_id = "${data.aws_route53_zone.tectonic.zone_id}"
  name    = "${var.tectonic_cluster_name}"
  type    = "A"
  ttl     = "60"
  records = ["${vsphere_virtual_machine.worker-vm.*.network_interface.0.ipv4_address}"]
}
