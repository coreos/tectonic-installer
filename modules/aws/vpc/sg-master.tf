resource "aws_security_group" "master" {
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  tags = "${merge(map(
      "Name", "${var.cluster_name}_master_sg",
      "KubernetesCluster", "${var.cluster_name}"
    ), var.extra_tags)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.master.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_icmp" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_ssh" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 22
  to_port     = 22

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_http" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 80
  to_port     = 80

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_https" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 443
  to_port     = 443

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_heapster" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 4194
  to_port   = 4194
  self      = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_heapster_from_worker" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 4194
  to_port   = 4194

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_flannel" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
  self      = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_flannel_from_worker" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.worker.id}"

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_node_exporter" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 9100
  to_port   = 9100
  self      = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_node_exporter_from_worker" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 9100
  to_port   = 9100

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_kubelet_insecure" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250
  self      = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_kubelet_insecure_from_worker" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_kubelet_secure" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 10255
  to_port   = 10255
  self      = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_kubelet_secure_from_worker" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.worker.id}"

  protocol  = "tcp"
  from_port = 10255
  to_port   = 10255

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_etcd" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 2379
  to_port   = 2380
  self      = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_bootstrap_etcd" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 12379
  to_port   = 12380
  self      = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_services" {
  type              = "ingress"
  security_group_id = "${aws_security_group.master.id}"

  protocol  = "tcp"
  from_port = 32000
  to_port   = 32767
  self      = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_ingress_services_from_console" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.console.id}"

  protocol  = "tcp"
  from_port = 32000
  to_port   = 32767

  lifecycle {
    create_before_destroy = true
  }
}
