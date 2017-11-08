variable "enabled" {
  description = "enable this module (true or false)"
}

variable "image_repo" {
  type = "string"

  description = <<EOF
repo component of image string to pull tectonic registry cache image from.
EOF
}

variable "image_tag" {
  type = "string"

  description = <<EOF
tag component of image string to pull tectonic registry cache image from.
EOF
}

variable "rkt_image_protocol" {
  type = "string"

  description = <<EOF
Protocol rkt will use when pulling images from registry.
Example: `docker://`
EOF
}

variable "rkt_insecure_options" {
  type = "string"

  description = <<EOF
Comma-separated list of insecure options for rkt.
Example: `image,tls`
EOF
}
