# placeholders for access_key / secret_key
# should be fed through env var or variable file
# https://www.terraform.io/docs/configuration/variables.html

variable vpc_name {
  description = "The name of the VPC to identify created resources."
}

variable base_domain {
  default     = "tectonic.dev.coreos.systems"
  description = "The base domain for this cluster's FQDN"
}

variable vpc_aws_region {
  description = "The target AWS region for the cluster"
}

variable vpc_cidr {
  default     = "10.0.0.0/16"
  description = "The CIDR range used for your entire VPC"
}

variable subnet_count {
  default     = 4
  description = "Number of private subnets to pre-create"
}

variable local_network_cidr {
  default     = "10.7.0.0/16"
  description = "IP range in the network your laptop is on (dosn't actually matter unless your instances need to connect to the local network your laptop is on)"
}

variable ovpn_password {
  description = "password to use when connecting"
}

variable ovpn_ami_ids {
  # For details see: https://docs.openvpn.net/how-to-tutorialsguides/virtual-platforms/amazon-ec2-appliance-ami-quick-start-guide/
  description = "AMI IDs of the OVPN appliance images per region."
  type        = "map"

  default = {
    us-west-1      = "ami-4a02492a"
    us-west-2      = "ami-d3e743b3"
    us-east-1      = "ami-bc3566ab"
    us-east-2      = "ami-10306a75"
    eu-west-1      = "ami-f53d7386"
    eu-central-1   = "ami-ad1fe6c2"
    ap-southeast-1 = "ami-a859ffcb"
    ap-northeast-1 = "ap-northeast-1"
    ap-southeast-2 = "ami-89477aea"
    sa-east-1      = "ami-0c069b60kj"
  }
}

output "ovpn_url" {
  value = "https://${aws_eip.ovpn_eip.public_ip}:443"
}

output "base_domain" {
  value = "${var.base_domain}"
}

output "private_zone_id" {
  value = "${aws_route53_zone.priv_zone.id}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "subnets" {
  value = "${aws_subnet.priv_subnet.*.id}"
}
