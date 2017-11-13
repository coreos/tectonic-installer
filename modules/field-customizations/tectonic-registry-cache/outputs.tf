output "id" {
  value = "${var.enabled ? sha1("${data.ignition_config.main.rendered}") : "" }"
}

output "append_configs" {
  value = ["${slice(list(map("source", data.ignition_config.main.rendered)),0,"${var.enabled ? 1 : 0}"}"]
}
