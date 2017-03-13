data "aws_route53_zone" "tectonic" {
  name = "${var.tectonic_base_domain}"
}

resource "aws_route53_record" "tectonic-api" {
  zone_id = "${data.aws_route53_zone.tectonic.zone_id}"
  name    = "${var.tectonic_cluster_name}-k8s"
  type    = "A"
  ttl     = "60"
  records = ["${openstack_compute_instance_v2.master_node.*.access_ip_v4}"]
}

resource "aws_route53_record" "tectonic-console" {
  zone_id = "${data.aws_route53_zone.tectonic.zone_id}"
  name    = "${var.tectonic_cluster_name}"
  type    = "A"
  ttl     = "60"
  records = ["${openstack_compute_instance_v2.worker_node.*.access_ip_v4}"]
}

resource "aws_route53_record" "etcd" {
  zone_id = "${data.aws_route53_zone.tectonic.zone_id}"
  name    = "${var.tectonic_cluster_name}-etc"
  type    = "A"
  ttl     = "60"
  records = ["${openstack_compute_instance_v2.etcd_node.*.access_ip_v4}"]
}

resource "aws_route53_record" "master_nodes" {
  count   = "${var.tectonic_master_count}"
  zone_id = "${data.aws_route53_zone.tectonic.zone_id}"
  name    = "${var.tectonic_cluster_name}-master-${count.index}"
  type    = "A"
  ttl     = "60"
  records = ["${openstack_compute_instance_v2.master_node.*.access_ip_v4[count.index]}"]
}

resource "aws_route53_record" "worker_nodes" {
  count   = "${var.tectonic_worker_count}"
  zone_id = "${data.aws_route53_zone.tectonic.zone_id}"
  name    = "${var.tectonic_cluster_name}-worker-${count.index}"
  type    = "A"
  ttl     = "60"
  records = ["${openstack_compute_instance_v2.worker_node.*.access_ip_v4[count.index]}"]
}
