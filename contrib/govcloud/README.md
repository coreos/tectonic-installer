# Internal Cluster

This directory contains Terraform configuration that provisions a VPC with a VPN connection and a PowerDNS server in AWS GovCloud.
This setup is not production ready and is designed to emulate a customer-like deployment in order to end-to-end test deploying Tectonic in AWS GovCloud using a required pre-created internal VPC.

This Terraform configuration provisions the following AWS resources by default:
* 1 VPC with name configured by `TF_VAR_vpc_name`
* 4 subnets in the VPC with count configured by `TF_VAR_subnet_count`
* 1 public subnet containing an internet gateway.
* 1 EC2 Container Linux instance in the public subnet acting as a NAT gateway to enable instances in the private subnet to initiate outbound traffic to the Internet and running docker containers for OpenVPN, PowerDNS (and mysql as the backend) and Nginx for serving OpenVPN client configuration.
* 1 VPN gateway and VPN connection

## Usage

### Install Terraform

[Download the Terraform binary](https://www.terraform.io/downloads.html) and install it.


### Configure Credentials

Any existing credentials available in the `~/.aws/credentials` file will automatically be used. Otherwise, make the AWS credentials available by exporting the following environment variables:

```
export AWS_ACCESS_KEY_ID=<aws-key-id>
export AWS_SECRET_ACCESS_KEY=<aws-key-secret>
```

### Additional Variables

Terraform will prompt for any unset required variables. These variables can be manually entered at every run, exported as environment variables, or configured with a [terraform.tfvars](https://www.terraform.io/docs/configuration/variables.html#variable-files) file that will be ignored by git and used for every run. Simply create a `terraform.tfvars` file and set any required variables or overrides

### Running

Validate the configuration and plan the run with:

```
terraform plan
```

Provision the infrastructure with:

```
terraform apply
```

### Connect to the VPN

Once the infrastructure is ready, Terraform will output an `ovpn_url` variable containing the URL of the OpenVPN Access Server. In order to connect to the VPN, take the following steps:

1. Navigate to `ovpn_url` and login to the Access Server with the username `openvpn` and the password provided when running Terraform.
2. Download the OpenVPN configuration file from the Access Server.
3. Follow the instructions for the appropriate OS to setup a VPN connection using the configuration file.
4. When establishing the VPN connection, use the same credentials used when connecting to the Access Server. If prompted, do not provide a private key password.

### Tectonic Installation

Once all the infrastructure is provisioned and the VPN connection is available, a Tectonic cluster can be installed in the VPC. When running the Tectonic installer, be sure to:

* Install Tectonic in the provisioned VPC by selecting the "Existing VPC" option and selecting the appropriate VPC ID in the GUI or by setting the `TF_VAR_tectonic_aws_external_vpc_id` environment variable.


### Tear Down

To tear down the infrastructure or to restart the process, run:

```
terraform destroy
```

### Troubleshooting

If `terraform apply` fails, Terraform will not automatically roll back the created resources. Before attempting to create the infrastructure again, the resources must be destroyed manually by running:

```
terraform destroy
```
