# Internal Clusters

This is a Terraform script for provisioning a VPC and subnets etc for a customer-like deployment.

This also provisions an OVPN server.

Both can be used to do a full end-to-end test of an "Internal Cluster" to an "Existing VPC".

This is does everything documented in [this google doc](https://docs.google.com/document/d/1c86qI6ehIgZBiND2oRd0q9KOc1hF0f2bMshVcWvF200/edit#).

## Usage

### Install Terraform

[Download the binary](https://www.terraform.io/downloads.html) and put it somewhere in your path.


### Configure Credentials

Any credentials existing in your `~/.aws/credentials` file will automatically be used. If you have multiple sets of creds you can set the `aws_profile` variable.

Export your AWS credentials:

```
export AWS_ACCESS_KEY_ID=<your-aws-key-id>
export AWS_SECRET_ACCESS_KEY=<your-aws-key-secret>
```

### Additional Variables

When running terraform it will prompt you for any unset required variables. You can type these in each time, export them as env variables, or create a [terraform.tfvars](https://www.terraform.io/docs/configuration/variables.html#variable-files) that will be git ignored and always used for each terraform run.
Just create a `terraform.tfvars` file and add set any required variables or overrides

### Running

Validate your configuration and see what will happen with:

```
terraform plan
```

When ready to run it:

```
terraform apply
```

Once complete the `ovpn_url` variable will be output.

1. Follow that link and login with the username `openvpn` and the password you configured.
2. Download the OpenVPN config file it presents you.
3. Follow the instructions for your platform to setup an OpenVPN connection using the file (Linux has this natively, OSX can use [TunnelBlick](https://tunnelblick.net)).
4. Enter the same username and password when connecting, do not provide a private key password.

**Manual DNS configuration**
Terraform does not support chaging SOA TTLs in Route53. You will need to find the Internal Hosted Zone that was created and modify the TTLs manually via the AWS Console if you intend to use this immediately.

**Tectonic Installation**
Once everything is provisioned you can now proceed with your Tectonic installer tests. Be sure to:

- Choose the private DNS Zone that was created
- Install with the "Existing VPC" option


### Tear Down

When finished with your infrastructure, or you want to start over:

```
terraform destroy
```

### Troubleshooting

If your apply fails it will not automatically roll back the created resources. You will need to manually run:

```
terraform destroy
```
