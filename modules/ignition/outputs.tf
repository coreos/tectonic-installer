output "max_user_watches_id" {
  value = "${data.ignition_file.max_user_watches.id}"
}

output "max_user_watches_rendered" {
  value = "${data.template_file.max_user_watches.rendered}"
}
