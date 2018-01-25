package terraformgenerator

import (
	"github.com/coreos/tectonic-installer/installer/pkg/config"
)

type GovCloud struct {
	AssetsS3BucketName      string `json:"tectonic_govcloud_assets_s3_bucket_name,omitempty"`
	DNSServerIp             string `json:"tectonic_govcloud_dns_server_ip,omitempty"`
	EtcdEC2Type             string `json:"tectonic_govcloud_etcd_ec2_type,omitempty"`
	EtcdExtraSGIDs          string `json:"tectonic_govcloud_etcd_extra_sg_ids,omitempty"`
	EtcdRootVolumeIOPS      string `json:"tectonic_govcloud_etcd_root_volume_iops,omitempty"`
	EtcdRootVolumeSize      string `json:"tectonic_govcloud_etcd_root_volume_size,omitempty"`
	EtcdRootVolumeType      string `json:"tectonic_govcloud_etcd_root_volume_type,omitempty"`
	ExternalMasterSubnetIDs string `json:"tectonic_govcloud_external_master_subnet_ids,omitempty"`
	ExternalPrivateZone     string `json:"tectonic_govcloud_external_private_zone,omitempty"`
	ExternalVPCID           string `json:"tectonic_govcloud_external_vpc_id,omitempty"`
	ExternalWorkerSubnetIDs string `json:"tectonic_govcloud_external_worker_subnet_ids,omitempty"`
	ExtraTags               string `json:"tectonic_govcloud_extra_tags,omitempty"`
	MasterCustomSubnets     string `json:"tectonic_govcloud_master_custom_subnets,omitempty"`
	MasterEC2Type           string `json:"tectonic_govcloud_master_ec2_type,omitempty"`
	MasterExtraSGIDs        string `json:"tectonic_govcloud_master_extra_sg_ids,omitempty"`
	MasterIAMRoleName       string `json:"tectonic_govcloud_master_iam_role_name,omitempty"`
	MasterRootVolumeIOPS    string `json:"tectonic_govcloud_master_root_volume_iops,omitempty"`
	MasterRootVolumeSize    string `json:"tectonic_govcloud_master_root_volume_size,omitempty"`
	MasterRootVolumeType    string `json:"tectonic_govcloud_master_root_volume_type,omitempty"`
	PrivateEndpoints        string `json:"tectonic_govcloud_private_endpoints,omitempty"`
	Profile                 string `json:"tectonic_govcloud_profile,omitempty"`
	PublicEndpoints         string `json:"tectonic_govcloud_public_endpoints,omitempty"`
	SSHKey                  string `json:"tectonic_govcloud_ssh_key,omitempty"`
	VPCCidrBlock            string `json:"tectonic_govcloud_vpc_cidr_block,omitempty"`
	WorkerCustomSubnets     string `json:"tectonic_govcloud_worker_custom_subnets,omitempty"`
	WorkerEC2Type           string `json:"tectonic_govcloud_worker_ec2_type,omitempty"`
	WorkerExtraSGIDs        string `json:"tectonic_govcloud_worker_extra_sg_ids,omitempty"`
	WorkerIAMRoleName       string `json:"tectonic_govcloud_worker_iam_role_name,omitempty"`
	WorkerLoadBalancers     string `json:"tectonic_govcloud_worker_load_balancers,omitempty"`
	WorkerRootVolumeIOPS    string `json:"tectonic_govcloud_worker_root_volume_iops,omitempty"`
	WorkerRootVolumeSize    string `json:"tectonic_govcloud_worker_root_volume_size,omitempty"`
	WorkerRootVolumeType    string `json:"tectonic_govcloud_worker_root_volume_type,omitempty"`
}

func NewGovCloud(cluster config.Cluster) GovCloud {
	return GovCloud{
	// AssetsS3BucketName:      "",
	// DNSServerIp:             "",
	// EtcdEC2Type:             "",
	// EtcdExtraSGIDs:          "",
	// EtcdRootVolumeIOPS:      "",
	// EtcdRootVolumeSize:      "",
	// EtcdRootVolumeType:      "",
	// ExternalMasterSubnetIDs: "",
	// ExternalPrivateZone:     "",
	// ExternalVPCID:           "",
	// ExternalWorkerSubnetIDs: "",
	// ExtraTags:               "",
	// MasterCustomSubnets:     "",
	// MasterEC2Type:           "",
	// MasterExtraSGIDs:        "",
	// MasterIAMRoleName:       "",
	// MasterRootVolumeIOPS:    "",
	// MasterRootVolumeSize:    "",
	// MasterRootVolumeType:    "",
	// PrivateEndpoints:        "",
	// Profile:                 "",
	// PublicEndpoints:         "",
	// SSHKey:                  "",
	// VPCCidrBlock:            "",
	// WorkerCustomSubnets:     "",
	// WorkerEC2Type:           "",
	// WorkerExtraSGIDs:        "",
	// WorkerIAMRoleName:       "",
	// WorkerLoadBalancers:     "",
	// WorkerRootVolumeIOPS:    "",
	// WorkerRootVolumeSize:    "",
	// WorkerRootVolumeType:    "",
	}
}
