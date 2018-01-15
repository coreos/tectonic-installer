package config

type Cluster struct {
	Console              `yaml:"Console"`
	ContainerLinux       `yaml:"ContainerLinux"`
	DNS                  `yaml:"DNS"`
	Etcd                 `yaml:"Etcd"`
	ExternalTLSMaterials `yaml:"ExternalTLSMaterials"`
	Masters              `yaml:"Masters"`
	Name                 string `yaml:"Name"`
	Networking           `yaml:"Networking"`
	Platform             string `yaml:"Platform"`
	Tectonic             `yaml:"Tectonic"`
	Update               `yaml:"Update"`
	Workers              `yaml:"Workers"`
}

type Config struct {
	Clusters []Cluster `yaml:"Clusters"`
}

type Console struct {
	AdminEmail    string `yaml:"AdminEmail"`
	AdminPassword string `yaml:"AdminPassword"`
}

type ContainerLinux struct {
	Channel string `yaml:"Channel"`
	Version string `yaml:"Version"`
}

type DNS struct {
	BaseDomain string `yaml:"BaseDomain"`
}

type Etcd struct {
	NodeCount       int      `yaml:"NodeCount"`
	MachineType     string   `yaml:"MachineType"`
	ExternalServers []string `yaml:"ExternalServers"`
}

type ExternalTLSMaterials struct {
	ValidityPeriod int    `yaml:"ValidityPeriod"`
	EtcdCACertPath string `yaml:"EtcdCACertPath"`
}

type Masters struct {
	NodeCount   int    `yaml:"NodeCount"`
	MachineType string `yaml:"MachineType"`
}

type Networking struct {
	Type        string `yaml:"Type"`
	MTU         string `yaml:"MTU"`
	NodeCIDR    string `yaml:"NodeCIDR"`
	ServiceCIDR string `yaml:"ServiceCIDR"`
	PodCIDR     string `yaml:"PodCIDR"`
}

type Tectonic struct {
	PullSecretPath string `yaml:"PullSecretPath"`
	LicensePath    string `yaml:"LicensePath"`
}

type Update struct {
	Server  string `yaml:"Server"`
	Channel string `yaml:"Channel"`
	AppID   string `yaml:"AppID"`
}

type Workers struct {
	NodeCount   int    `yaml:"NodeCount"`
	MachineType string `yaml:"MachineType"`
}
