output "vpc_id" {
  value = "${data.aws_vpc.cluster_vpc.id}"
}

output "master_subnet_ids" {
  value = ["${data.aws_subnet.master.*.id}"]
}

output "worker_subnet_ids" {
  value = ["${data.aws_subnet.worker.*.id}"]
}

output "etcd_sg_id" {
  value = "${aws_security_group.etcd.id}"
}

output "master_sg_id" {
  value = "${aws_security_group.master.id}"
}

output "worker_sg_id" {
  value = "${aws_security_group.worker.id}"
}

output "api_sg_id" {
  value = "${aws_security_group.api.id}"
}

output "console_sg_id" {
  value = "${aws_security_group.console.id}"
}
