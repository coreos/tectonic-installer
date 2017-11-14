variable "bootstrapping_host" {
  type = "string"
}

variable "wait_time" {
  type    = "string"
  default = "0"

  description = <<EOF
Seconds to wait before sshing.
This can be used to avoid a machine reboot to happen while ssh terraform provisioners are running.
EOF
}

variable "_dependencies" {
  type = "list"
}
