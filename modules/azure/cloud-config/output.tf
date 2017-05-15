output "content" {
 value = "${data.template_file.cloud-config.rendered}"
}
