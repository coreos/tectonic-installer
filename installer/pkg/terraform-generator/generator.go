package terraformgenerator

import (
	"encoding/json"

	"github.com/coreos/tectonic-installer/installer/pkg/config"
)

type TerraformGenerator struct {
	config.Cluster
}

type TFVars struct {
	AWS       `json:",inline"`
	Azure     `json:",inline"`
	GCP       `json:",inline"`
	GovCloud  `json:",inline"`
	Metal     `json:",inline"`
	OpenStack `json:",inline"`
	Tectonic  `json:",inline"`
	VMware    `json:",inline"`
}

func New(cluster config.Cluster) TerraformGenerator {
	return TerraformGenerator{
		Cluster: cluster,
	}
}

func (c TerraformGenerator) TFVars() (string, error) {
	tfVars := TFVars{
		AWS:       NewAWS(c.Cluster),
		Azure:     NewAzure(c.Cluster),
		GCP:       NewGCP(c.Cluster),
		GovCloud:  NewGovCloud(c.Cluster),
		Metal:     NewMetal(c.Cluster),
		OpenStack: NewOpenStack(c.Cluster),
		Tectonic:  NewTectonic(c.Cluster),
		VMware:    NewVMWare(c.Cluster),
	}

	data, err := json.MarshalIndent(&tfVars, "", "  ")
	if err != nil {
		return "", err
	}

	return string(data), nil
}
