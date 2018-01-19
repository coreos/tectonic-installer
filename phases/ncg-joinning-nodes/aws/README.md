# NCG joinning nodes
## WIP

At bootstrap node phase:

`terraform apply -var-file your-vars.tf  ../../platforms/aws/` 

`terraform destroy -target aws_route53_record.tectonic_ncg -var-file terraform-mine.tfvars ../../platforms/aws/`

At ncg joinning nodes phase:

`terraform import aws_autoscaling_group.masters "cluster-name"-masters`

`terraform apply -var-file your-vars.tf`
