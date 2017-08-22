output "max_user_watches_id" {
  value = "${data.ignition_file.max_user_watches.id}"
}

output "max_user_watches_rendered" {
  value = "${data.template_file.max_user_watches.rendered}"
}

output "docker_dropin_id" {
  value = "${data.ignition_systemd_unit.docker_dropin.id}"
}

output "docker_dropin_rendered" {
  value = "${data.template_file.docker_dropin.rendered}"
}
