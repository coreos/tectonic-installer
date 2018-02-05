data "terraform_remote_state" "bootstrap-assets" {
  backend = "local"

  config {
    path = "${path.module}/../../${var.tectonic_cluster_name}/assets.tfstate"
  }
}

locals {
  cluster_id            = "${data.terraform_remote_state.bootstrap-assets.cluster_id}"
  s3_bucket             = "${data.terraform_remote_state.bootstrap-assets.s3_bucket}"
  s3_bucket_domain_name = "${data.terraform_remote_state.bootstrap-assets.s3_bucket_domain_name}"
  kubeconfig_content    = "${data.terraform_remote_state.bootstrap-assets.kubeconfig_content}"
}
