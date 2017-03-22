resource "aws_internet_gateway" "igw" {
  count  = "${var.external_vpc_id == "" ? 1 : 0}"
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"
}

resource "aws_route_table" "default" {
  count  = "${var.external_vpc_id == "" ? 1 : 0}"
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  tags {
    Name              = "public"
    KubernetesCluster = "${var.cluster_name}"
  }
}

resource "aws_main_route_table_association" "main_vpc_routes" {
  vpc_id         = "${data.aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.default.id}"
}

resource "aws_route" "igw_route" {
  count                  = "${var.external_vpc_id == "" ? 1 : 0}"
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = "${aws_route_table.default.id}"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_subnet" "master_subnet" {
  count             = "${var.external_vpc_id == "" ? var.az_count : 0}"
  cidr_block        = "${cidrsubnet(data.aws_vpc.cluster_vpc.cidr_block, 4, count.index)}"
  vpc_id            = "${data.aws_vpc.cluster_vpc.id}"
  availability_zone = "${data.aws_availability_zones.azs.names[count.index]}"

  tags {
    Name                     = "master-${data.aws_availability_zones.azs.names[count.index]}"
    KubernetesCluster        = "${var.cluster_name}"
    "kubernetes.io/role/elb" = ""
  }
}

resource "aws_route_table_association" "route_net" {
  count          = "${var.external_vpc_id == "" ? var.az_count : 0}"
  route_table_id = "${aws_route_table.default.id}"
  subnet_id      = "${aws_subnet.master_subnet.*.id[count.index]}"
}

resource "aws_eip" "nat_eip" {
  count = "${var.external_vpc_id == "" ? var.az_count : 0}"
  vpc   = true
}

resource "aws_nat_gateway" "nat_gw" {
  count         = "${var.external_vpc_id == "" ? var.az_count : 0}"
  allocation_id = "${aws_eip.nat_eip.*.id[count.index]}"
  subnet_id     = "${aws_subnet.master_subnet.*.id[count.index]}"
}
