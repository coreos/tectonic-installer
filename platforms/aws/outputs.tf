####################################
#  REEXPOSE ETCD OUTPUTS
#  subdir > modules/aws/etcd
#  file > outputs.tf
####################################

output "etcd_endpoints" {
	value = "${module.etcd.endpoints}"
}

####################################
#  REEXPOSE MASTERS OUTPUTS
#  subdir > modules/aws/master-asg
#  file > outputs.tf
####################################

output "masters_ingress_external_fqdn" {
	value = "${module.masters.ingress_external_fqdn}"
}

output "masters_ingress_internal_fqdn" {
	value = "${module.masters.ingress_internal_fqdn}"
}

output "masters_api_external_fqdn" {
	value = "${module.masters.api_external_fqdn}"
}

output "masters_api_internal_fqdn" {
	value = "${module.masters.api_internal_fqdn}"
}
####################################
#  REEXPOSE IGNITION-MASTERS OUTPUTS
#  subdir > modules/aws/ignition
#  file > outputs.tf
####################################

output "ignition_masters_ignition" {
	value = "${module.ignition-masters.ignition}"
}

####################################
#  REEXPOSE IGNITION-WORKERS OUTPUTS
#  subdir > modules/aws/ignition
#  file > outputs.tf
####################################

output "ignition_workers_ignition" {
	value = "${module.ignition-workers.ignition}"
}


####################################
#  REEXPOSE VPC OUTPUTS   
#  subdir > modules/aws/vpc
#  file > outputs.tf
####################################

output "vpc_vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_master_subnet_ids" {
  value = "${module.vpc.master_subnet_ids}"
}

output "vpc_worker_subnet_ids" {
  value = "${module.vpc.worker_subnet_ids}"
}

output "vpc_etcd_sg_id" {
  value = "${module.vpc.etcd_sg_id}"
}

output "vpc_master_sg_id" {
  value = "${module.vpc.master_sg_id}"
}

output "vpc_worker_sg_id" {
  value = "${module.vpc.worker_sg_id}"
}

output "vpc_api_sg_id" {
  value = "${module.vpc.api_sg_id}"
}

output "vpc_console_sg_id" {
  value = "${module.vpc.console_sg_id}"
}

####################################
#  REEXPOSE TECTONIC OUTPUTS   
#  subdir > modules/tectonic
#  file > outputs.tf
####################################

output "tectonic_id" {
	value = "${module.tectonic.id}"
}

output "tectonic_cluster_id" {
	value = "${module.tectonic.cluster_id}"
}
