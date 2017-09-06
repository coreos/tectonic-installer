data "external" "version" {
  count   = "${var.version == "latest" ? 1 : 0}"
  program = ["sh", "-c", "curl https://${var.channel}.release.core-os.net/amd64-usr/current/version.txt | sed -n 's/COREOS_VERSION=\\(.*\\)$/{\"version\": \"\\1\"}/p'"]
}
