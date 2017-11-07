output "id" {
  value = "${length(var.cacertificates) > 0 ? sha1("${data.ignition_config.main.rendered}") : "" }"
}

output "append_configs" {
  value = ["${slice(list(map("source", data.ignition_config.main.rendered)),0,signum(length(var.cacertificates)) )}"]
}
