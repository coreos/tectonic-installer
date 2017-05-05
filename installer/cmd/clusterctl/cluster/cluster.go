package cluster

// Cluster represents a Tectonic instance.
type Cluster struct {
	// Config describes the parameters the cluster is to be provisioned with.
	*Config

	// Variants that will be applied to the cluster, key is the scenario the variant is from.
	Scenarios map[*Scenario]*Config
}

// Tolerable validates whether scenario s with name n can be applied to this cluster. A scenario may not be applied
// because another variant from the scenario has already been applied or there's a constraint with an existing scenario.
func (c Cluster) Tolerable(s *Scenario) bool {
	// should not be applied with avoided scenarios, or it's own scenario
	rejects := append(s.Avoid, s.Name)

	for cur := range c.Scenarios {
		for _, reject := range rejects {
			if reject == cur.Name {
				return false
			}
		}
	}
	return true
}

// Add applies the config to the cluster and records the scenarios name. Restrictions are not checked.
func (c *Cluster) Add(scenario *Scenario, variant *Config) {
	if scenario != nil {
		c.Scenarios[scenario] = variant
	}
}

type Clusters []*Cluster

// Assign returns a cluster which can run the given scenario. Nil is returned if no suitable cluster exists.
func (clusters Clusters) Assign(s *Scenario) *Cluster {
	for _, c := range clusters {
		if c.Tolerable(s) {
			return c
		}
	}
	return nil
}
