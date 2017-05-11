package cluster

import (
	"testing"

	"fmt"
	"github.com/coreos/tectonic-installer/installer/server"
	"github.com/coreos/tectonic-installer/installer/server/terraform"
	"k8s.io/kubernetes/_output/local/go/src/k8s.io/kubernetes/staging/src/k8s.io/apimachinery/pkg/util/json"
)

func exampleSpec() *Spec {
	return &Spec{
		Scenarios: Scenarios{
			{
				Name: "self-hosted-etcd",
				Variants: []*Config{
					{
						Name: "disabled",
						Input: &server.TerraformApplyHandlerInput{
							Variables: map[string]interface{}{
								"tectonic_experimental": false,
							},
						},
					},
					{
						Name: "enabled",
						Input: &server.TerraformApplyHandlerInput{
							Variables: map[string]interface{}{
								"tectonic_experimental": true,
							},
						},
					},
				},
			},
		},
		Config: &Config{
			Name: "test_cluster",
			Input: &server.TerraformApplyHandlerInput{
				DryRun:     false,
				License:    "<TECTONIC_LICENSE>",
				Platform:   "aws",
				PullSecret: "<TECTONIC_PULL_SECRET>",
				Credentials: terraform.Credentials{
					AWSCredentials: &terraform.AWSCredentials{
						AWSAccessKeyID:     "awsAccessKeyId",
						AWSRegion:          "us-west-1",
						AWSSecretAccessKey: "awsSecretAccessKey",
					},
				},
				Variables: map[string]interface{}{
					"tectonic_admin_email":               "admin@example.com",
					"tectonic_aws_etcd_ec2_type":         "t2.large",
					"tectonic_aws_etcd_root_volume_size": 300,
					"tectonic_aws_etcd_root_volume_type": "gp2",
					"tectonic_aws_extra_tags": map[string]string{
						"test_tag": "testing",
					},
					"tectonic_aws_master_custom_subnets": map[string]string{
						"us-west-1a": "10.0.0.0/19",
						"us-west-1c": "10.0.32.0/19",
					},
					"tectonic_aws_master_ec2_type":         "t2.large",
					"tectonic_aws_master_root_volume_size": 33,
					"tectonic_aws_master_root_volume_type": "gp2",
					"tectonic_aws_ssh_key":                 "some-ssh-key",
					"tectonic_aws_vpc_cidr_block":          "10.0.0.0/16",
					"tectonic_aws_worker_custom_subnets": map[string]string{
						"us-west-1a": "10.0.64.0/19",
						"us-west-1c": "10.0.96.0/19",
					},
					"tectonic_aws_worker_ec2_type":         "t2.medium",
					"tectonic_aws_worker_root_volume_iops": 1000,
					"tectonic_aws_worker_root_volume_size": 1000,
					"tectonic_aws_worker_root_volume_type": "io1",
					"tectonic_base_domain":                 "example.com",
					"tectonic_cl_channel":                  "stable",
					"tectonic_cluster_cidr":                "10.2.0.0/16",
					"tectonic_cluster_name":                "test",
					"tectonic_dns_name":                    "test",
					"tectonic_etcd_count":                  3,
					"tectonic_master_count":                1,
					"tectonic_service_cidr":                "10.3.0.0/16",
					"tectonic_worker_count":                3,
				},
			},
		},
	}
}

func TestRenderClusterFromSpec(t *testing.T) {
	spec := exampleSpec()
	data, err := json.Marshal(spec)
	if err != nil {
		t.Fatal(err)
	}

	fmt.Println(string(data))
}
