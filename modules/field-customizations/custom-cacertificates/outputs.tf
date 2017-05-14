output "id" {
  value = "${length(var.cacertificates) > 0 ? sha1("${data.ignition_config.main.rendered}") : "" }"
}

output "local_file_id" {
  value = "${sha1("${join(" ",local_file.tectonic-custom-cacert.*.id)}")}"
}

output "ignition_files" {
  value = ["${data.ignition_config.main.files}"]
}

output "ignition_systemd_units" {
  value = ["${data.ignition_config.main.systemd}"]
}

output "ignition_config_content" {
  value = "${data.ignition_config.main.rendered}"
}

output "ignition_config_data_url" {
  value = "${length(var.cacertificates) > 0 ? format("data:application/json;base64,%s", base64encode(data.ignition_config.main.rendered)) : ""}"
}
