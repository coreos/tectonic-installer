data "aws_route53_zone" "tectonic-ext" {
  name = "${var.base_domain}"
}

data "aws_vpc" "cluster_vpc" {
  id = "${var.vpc_id}"
}

resource "aws_route53_zone" "tectonic-int" {
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"
  name   = "${var.base_domain}"
}

resource "aws_route53_record" "api-internal" {
  zone_id = "${aws_route53_zone.tectonic-int.zone_id}"
  name    = "${var.cluster_name}-k8s.${var.base_domain}"
  type    = "A"

  alias {
    name                   = "${var.api_internal_elb["dns_name"]}"
    zone_id                = "${var.api_internal_elb["zone_id"]}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api-external" {
  zone_id = "${data.aws_route53_zone.tectonic-ext.zone_id}"
  name    = "${var.cluster_name}-k8s.${var.base_domain}"
  type    = "A"

  alias {
    name                   = "${var.api_external_elb["dns_name"]}"
    zone_id                = "${var.api_external_elb["zone_id"]}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ingress-public" {
  zone_id = "${data.aws_route53_zone.tectonic-ext.zone_id}"
  name    = "${var.cluster_name}.${var.base_domain}"
  type    = "A"

  alias {
    name                   = "${var.console_elb["dns_name"]}"
    zone_id                = "${var.console_elb["zone_id"]}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ingress-private" {
  zone_id = "${aws_route53_zone.tectonic-int.zone_id}"
  name    = "${var.cluster_name}.${var.base_domain}"
  type    = "A"

  alias {
    name                   = "${var.console_elb["dns_name"]}"
    zone_id                = "${var.console_elb["zone_id"]}"
    evaluate_target_health = true
  }
}
