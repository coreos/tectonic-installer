data "ignition_systemd_unit" "tx-off" {
  name    = "tx-off.service"
  enabled = true
  content = "${file("${path.module}/resources/tx-off.service")}"
}
