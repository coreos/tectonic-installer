resource "aws_security_group" "etcd" {
  count  = "${var.enable_etcd_sg}"
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  tags = "${merge(map(
      "Name", "${var.cluster_name}_etcd_sg",
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
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    self      = true

    security_groups = ["${var.external_sg_master == "" ? join(" ", aws_security_group.master.*.id) : var.external_sg_master }"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 2379
    to_port   = 2379
    self      = true

    security_groups = ["${var.external_sg_master == "" ? join(" ", aws_security_group.master.*.id) : var.external_sg_master }"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 2380
    to_port   = 2380
    self      = true
  }
}

# resource "aws_security_group_rule" "etcd_ssh_from_master" {
#   count                    = "${var.external_sg_master == "" && var.enable_etcd_sg ? 1 : 0}"
#   type                     = "ingress"
#   security_group_id        = "${aws_security_group.etcd.id}"
#   source_security_group_id = "${aws_security_group.master.id}"
# 
#   protocol  = "tcp"
#   from_port = 22
#   to_port   = 22
# }
# 
# resource "aws_security_group_rule" "etcd_ssh_from_external_master" {
#   count                    = "${var.external_sg_master != "" && var.enable_etcd_sg ? 1 : 0}"
#   type                     = "ingress"
#   security_group_id        = "${aws_security_group.etcd.id}"
#   source_security_group_id = "${var.external_sg_master}"
# 
#   protocol  = "tcp"
#   from_port = 22
#   to_port   = 22
# }
# 
# resource "aws_security_group_rule" "etcd_client_from_master" {
#   count                    = "${var.external_sg_master == "" && var.enable_etcd_sg ? 1 : 0}"
#   type                     = "ingress"
#   security_group_id        = "${aws_security_group.etcd.id}"
#   source_security_group_id = "${aws_security_group.master.id}"
# 
#   protocol  = "tcp"
#   from_port = 2379
#   to_port   = 2379
# }
# 
# resource "aws_security_group_rule" "etcd_client_from_external_master" {
#   count                    = "${var.external_sg_master != "" && var.enable_etcd_sg ? 1 : 0}"
#   type                     = "ingress"
#   security_group_id        = "${aws_security_group.etcd.id}"
#   source_security_group_id = "${var.external_sg_master}"
# 
#   protocol  = "tcp"
#   from_port = 2379
#   to_port   = 2379
# }
# 

