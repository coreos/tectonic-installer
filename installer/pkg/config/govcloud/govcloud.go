package govcloud

import (
	"github.com/coreos/tectonic-installer/installer/pkg/config/govcloud/etcd"
	"github.com/coreos/tectonic-installer/installer/pkg/config/govcloud/master"
	"github.com/coreos/tectonic-installer/installer/pkg/config/govcloud/worker"
)

type External struct {
	MasterSubnetIDs string `json:"tectonic_govcloud_external_master_subnet_ids,omitempty" yaml:"masterSubnetIDs,omitempty"`
	PrivateZone     string `json:"tectonic_govcloud_external_private_zone,omitempty" yaml:"privateZone,omitempty"`
	VPCID           string `json:"tectonic_govcloud_external_vpc_id,omitempty" yaml:"vpcID,omitempty"`
	WorkerSubnetIDs string `json:"tectonic_govcloud_external_worker_subnet_ids,omitempty" yaml:"workerSubnetIDs,omitempty"`
}

type GovCloud struct {
	AssetsS3BucketName        string `json:"tectonic_govcloud_assets_s3_bucket_name,omitempty" yaml:"assetsS3BucketName,omitempty"`
	AutoScalingGroupExtraTags string `json:"tectonic_autoscaling_group_extra_tags,omitempty" yaml:"autoScalingGroupExtraTags,omitempty"`
	DNSServerIP               string `json:"tectonic_govcloud_dns_server_ip,omitempty" yaml:"dnsServerIP,omitempty"`
	EC2AMIOverride            string `json:"tectonic_govcloud_ec2_ami_override,omitempty" yaml:"ec2AMIOverride,omitempty"`
	etcd.Etcd                 `json:",inline" yaml:"etcd,omitempty"`
	External                  `json:",inline" yaml:"external,omitempty"`
	ExtraTags                 string `json:"tectonic_govcloud_extra_tags,omitempty" yaml:"extraTags,omitempty"`
	InstallerRole             string `json:"tectonic_govcloud_installer_role,omitempty" yaml:"installerRole,omitempty"`
	master.Master             `json:",inline" yaml:"master,omitempty"`
	PrivateEndpoints          bool   `json:"tectonic_govcloud_private_endpoints,omitempty" yaml:"privateEndpoints,omitempty"`
	Profile                   string `json:"tectonic_govcloud_profile,omitempty" yaml:"profile,omitempty"`
	PublicEndpoints           bool   `json:"tectonic_govcloud_public_endpoints,omitempty" yaml:"publicEndpoints,omitempty"`
	Region                    string `json:"tectonic_govcloud_region,omitempty" yaml:"region,omitempty"`
	SSHKey                    string `json:"tectonic_govcloud_ssh_key,omitempty" yaml:"sshKey,omitempty"`
	VPCCIDRBlock              string `json:"tectonic_govcloud_vpc_cidr_block,omitempty" yaml:"vpcCIDRBlock,omitempty"`
	worker.Worker             `json:",inline" yaml:"worker,omitempty"`
}
