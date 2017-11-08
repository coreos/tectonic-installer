output "local_file_id" {
  value = "${sha1("${module.tectonic-registry-cache.local_file_id} ${module.custom-cacertificates.local_file_id}")}"
}

output "ignition" {
  value = "${data.ignition_config.main.rendered}"
}
