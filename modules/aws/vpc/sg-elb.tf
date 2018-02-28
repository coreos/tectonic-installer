resource "aws_security_group" "api" {
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  tags = "${merge(map(
      "Name", "${var.cluster_name}_api_sg",
      "kubernetes.io/cluster/${var.cluster_name}", "owned",
      "tectonicClusterID", "${var.cluster_id}"
    ), var.extra_tags)}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = "${var.custom_sg_cidrs}"
    from_port   = 443
    to_port     = 443
  }
}

resource "aws_security_group_rule" "api_ingress_https_from_master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.api.id}"
  source_security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 443
  to_port   = 443
}

resource "aws_security_group_rule" "api_ingress_https_from_worker" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.api.id}"
  source_security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 443
  to_port   = 443
}

resource "aws_security_group_rule" "api_ingress_https_from_console" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.api.id}"
  source_security_group_id = "${aws_security_group.console.id}"

  protocol  = "tcp"
  from_port = 443
  to_port   = 443
}

resource "aws_security_group" "console" {
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  tags = "${merge(map(
      "Name", "${var.cluster_name}_console_sg",
      "kubernetes.io/cluster/${var.cluster_name}", "owned",
      "tectonicClusterID", "${var.cluster_id}"
    ), var.extra_tags)}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = "${var.custom_sg_cidrs}"
    from_port   = 80
    to_port     = 80
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = "${var.custom_sg_cidrs}"
    from_port   = 443
    to_port     = 443
  }
}

resource "aws_security_group_rule" "console_ingress_http_from_master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.console.id}"
  source_security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 80
  to_port   = 80
}

resource "aws_security_group_rule" "console_ingress_https_from_master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.console.id}"
  source_security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 443
  to_port   = 443
}

resource "aws_security_group_rule" "console_ingress_http_from_worker" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.console.id}"
  source_security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 80
  to_port   = 80
}

resource "aws_security_group_rule" "console_ingress_https_from_worker" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.console.id}"
  source_security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 443
  to_port   = 443
}

resource "aws_security_group_rule" "console_ingress_http_from_api" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.console.id}"
  source_security_group_id = "${aws_security_group.api.id}"

  protocol  = "tcp"
  from_port = 80
  to_port   = 80
}

resource "aws_security_group_rule" "console_ingress_https_from_api" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.console.id}"
  source_security_group_id = "${aws_security_group.api.id}"

  protocol  = "tcp"
  from_port = 443
  to_port   = 443
}
