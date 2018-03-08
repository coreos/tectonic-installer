// This could be encapsulated as a data source
data "terraform_remote_state" "bootstrap" {
  backend = "local"

  config {
    path = "${path.cwd}/bootstrap.tfstate"
  }
}

locals {
  aws_launch_configuration_master_bootstrap = "${data.terraform_remote_state.bootstrap.aws_launch_configuration_master_bootstrap}"
  subnet_ids_masters                        = "${data.terraform_remote_state.bootstrap.subnet_ids_masters}"
  aws_lbs_masters                           = "${data.terraform_remote_state.bootstrap.aws_lbs_masters}"
  cluster_id                                = "${data.terraform_remote_state.bootstrap.cluster_id}"
}
