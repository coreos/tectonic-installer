package etcd

type Etcd struct {
	EC2Type     string `json:"tectonic_aws_etcd_ec2_type,omitempty" yaml:"ec2Type,omitempty"`
	ExtraSGIDs  string `json:"tectonic_aws_etcd_extra_sg_ids,omitempty" yaml:"extraSGIDs,omitempty"`
	IAMRoleName string `json:"tectonic_aws_etcd_iam_role_name,omitempty" yaml:"iamRoleName,omitempty"`
	RootVolume  `json:",inline" yaml:"rootVolume,omitempty"`
}

type RootVolume struct {
	IOPS int    `json:"tectonic_aws_etcd_root_volume_iops,omitempty" yaml:"iops,omitempty"`
	Size int    `json:"tectonic_aws_etcd_root_volume_size,omitempty" yaml:"size,omitempty"`
	Type string `json:"tectonic_aws_etcd_root_volume_type,omitempty" yaml:"type,omitempty"`
}
