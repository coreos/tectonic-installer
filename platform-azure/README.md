# Azure

1. Setup your DNS zone in a resource group called `tectonic-dns-group` or specify a different resource group. We use a separate resource group assuming that you have a zone that you already want to use.
1. Create a folder with the cluster's name under `./build` (e.g. `./build/<cluster-name>`)
1. Copy the `assets-<cluster-name>.zip` to `./boot/<cluster-name>`

```
make PLATFORM=azure CLUSTER=eugene
```

*Common Prerequsities*

1. Configure AWS credentials via environment variables.
[See docs](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-environment)
1. Configure a region by setting `AWS_REGION` environment variable
1. Run through the official Tectonic intaller steps without clicking `Submit` on the last step. 
Instead click on `Manual boot` below to download the assets zip file.
1. Create a folder with the cluster's name under `./build` (e.g. `./build/<cluster-name>`)
1. Copy the `assets-<cluster-name>.zip` to `./boot/<cluster-name>`

## Using Autoscaling groups

1. Ensure all *prerequsities* are met.
1. From the root of the repo, run `make PLATFORM=aws-asg CLUSTER=<cluster-name>`

To clean up run `make destroy PLATFORM=aws-asg CLUSTER=<cluster-name>`

