output "id" {
  value = "${var.enabled ? sha1("${data.ignition_config.main.rendered}") : "" }"
}

output "local_file_id" {
  # no local_file resources in this module to keep track of
  # if local_file resources are added to this module,
  # see modules/field-customizations/custom-cacertificates/outputs.tf
  # and look at local_file_ids output block
  value = ""
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
  value = "${var.enabled ? format("data:application/json+gzip;base64,%s", base64encode(data.ignition_config.main.rendered)) : ""}"
}
