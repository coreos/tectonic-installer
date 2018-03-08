package master

type Master struct {
	CustomSubnets string `json:"tectonic_govcloud_master_custom_subnets,omitempty" yaml:"customSubnets,omitempty"`
	EC2Type       string `json:"tectonic_govcloud_master_ec2_type,omitempty" yaml:"ec2Type,omitempty"`
	ExtraSGIDs    string `json:"tectonic_govcloud_master_extra_sg_ids,omitempty" yaml:"extraSGIDs,omitempty"`
	IAMRoleName   string `json:"tectonic_govcloud_master_iam_role_name,omitempty" yaml:"iamRoleName,omitempty"`
	RootVolume    `json:",inline" yaml:"RootVolume,omitempty"`
}

type RootVolume struct {
	IOPS int    `json:"tectonic_govcloud_master_root_volume_iops,omitempty" yaml:"iops,omitempty"`
	Size int    `json:"tectonic_govcloud_master_root_volume_size,omitempty" yaml:"size,omitempty"`
	Type string `json:"tectonic_govcloud_master_root_volume_type,omitempty" yaml:"type,omitempty"`
}
