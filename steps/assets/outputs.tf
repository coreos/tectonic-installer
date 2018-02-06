output "kube_dns_service_ip" {
  value = "${module.bootkube.kube_dns_service_ip}"
}

output "bootkube_service_id" {
  value = "${module.bootkube.systemd_service_id}"
}

output "bootkube_service" {
  value = "${module.bootkube.systemd_service_rendered}"
}

output "bootkube_path_unit_id" {
  value = "${module.bootkube.systemd_path_unit_id}"
}

output "tectonic_service_id" {
  value = "${module.tectonic.systemd_service_id}"
}

output "tectonic_path_unit_id" {
  value = "${module.tectonic.systemd_path_unit_id}"
}

output "tectonic_bucket" {
  value = "${aws_s3_bucket_object.tectonic_assets.bucket}"
}

output "tectonic_key" {
  value = "${aws_s3_bucket_object.tectonic_assets.key}"
}

output "kubeconfig_content" {
  value = "${module.bootkube.kubeconfig}"
}

output "s3_bucket" {
  value = "${aws_s3_bucket.tectonic.bucket}"
}

output "s3_bucket_domain_name" {
  value = "${aws_s3_bucket.tectonic.bucket_domain_name}"
}

output "cluster_id" {
  value = "${module.tectonic.cluster_id}"
}
