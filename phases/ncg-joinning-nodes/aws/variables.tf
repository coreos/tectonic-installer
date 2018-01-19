variable "tectonic_aws_region" {
  type        = "string"
  default     = "eu-west-1"
  description = "The target AWS region for the cluster."
}

variable "tectonic_aws_profile" {
  description = <<EOF
(optional) This declares the AWS credentials profile to use.
EOF

  type    = "string"
  default = "default"
}
