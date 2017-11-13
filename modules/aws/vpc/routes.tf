locals {
  worker_rtb_count = "${ var.disable_s3_vpc_endpoint ? 0 : local.worker_subnet_count }"
  master_rtb_count = "${ var.disable_s3_vpc_endpoint ? 0 : local.master_subnet_count }"

  worker_rtb_ids = ["${data.aws_route_table.worker.*.id}"]
  master_rtb_ids = ["${data.aws_route_table.master.*.id}"]
}

resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
  count        = "${var.disable_s3_vpc_endpoint ? 0 : 1}"
  vpc_id       = "${local.vpc_id}"
  service_name = "${format("com.amazonaws.%s.s3",data.aws_region.current.name)}"
}

resource "aws_vpc_endpoint_route_table_association" "worker_s3" {
  count           = "${local.worker_rtb_count}"
  vpc_endpoint_id = "${element(aws_vpc_endpoint.s3_vpc_endpoint.*.id,0)}"
  route_table_id  = "${local.worker_rtb_ids[count.index]}"
}

resource "aws_vpc_endpoint_route_table_association" "master_s3" {
  count           = "${local.master_rtb_count}"
  vpc_endpoint_id = "${element(aws_vpc_endpoint.s3_vpc_endpoint.*.id,0)}"
  route_table_id  = "${local.master_rtb_ids[count.index]}"
}
