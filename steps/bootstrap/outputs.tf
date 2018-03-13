# Masters
output "aws_launch_configuration_masters" {
  value = "${module.masters.aws_launch_configuration}"
}

output "aws_launch_configuration_master_bootstrap" {
  value = "${module.masters.aws_launch_configuration_master_bootstrap}"
}

output "subnet_ids_masters" {
  value = "${module.masters.subnet_ids}"
}

output "aws_lbs_masters" {
  value = "${module.masters.aws_lbs}"
}

output "cluster_id" {
  value = "${module.masters.cluster_id}"
}

# Workers
output "aws_launch_configuration_workers" {
  value = "${module.workers.aws_launch_configuration}"
}

output "subnet_ids_workers" {
  value = "${module.workers.subnet_ids}"
}
