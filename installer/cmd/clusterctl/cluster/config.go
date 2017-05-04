package cluster

import (
	"github.com/coreos/tectonic-installer/installer/server"
)

// Config holds the configuration needed to setup an individual cluster.
type Config struct {
	server.TerraformApplyHandlerInput
}

// Apply overrides configuration using values from another config. Currently only works on variables.
func (c *Config) Apply(top Config) {
	for k, v := range top.Variables {
		c.Variables[k] = v
	}
}