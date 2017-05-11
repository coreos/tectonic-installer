package main

import (
	"encoding/json"
	"fmt"

	"github.com/coreos/tectonic-installer/installer/cmd/clusterctl/cluster"
)

func generate(specData []byte) error {
	c := &cluster.Spec{}
	if err := json.Unmarshal(specData, c); err != nil {
		return fmt.Errorf("failed to read spec: %v", err)
	}

	clusters, err := c.Build()
	if err != nil {
		return fmt.Errorf("failed to create clusters from spec: %v", err)
	}

	for _, cluster := range clusters {
		data, err := json.Marshal(&cluster)
		if err != nil {
			return fmt.Errorf("failed to output cluster: %v", err)
		}

		fmt.Println(string(data))
	}
}
