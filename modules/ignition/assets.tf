data "template_file" "max_user_watches" {
  template = "${file("${path.module}/resources/sysctl.d/max-user-watches.conf")}"
}

data "ignition_file" "max_user_watches" {
  filesystem = "root"
  path       = "/etc/sysctl.d/max-user-watches.conf"
  mode       = 0644

  content {
    content = "${data.template_file.max_user_watches.rendered}"
  }
}
