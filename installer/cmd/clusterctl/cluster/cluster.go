package cluster

// Cluster represents a Tectonic instance.
type Cluster struct {
	// Config describes the parameters the cluster is to be provisioned with.
	*Config

	// ActiveScenarios are the scenarios that are currently being applied to the cluster
	ActiveScenarios []string
}

// Tolerable validates whether scenario s with name n can be applied to this cluster. A scenario may not be applied
// because another variant from the scenario has already been applied or there's a constraint with an existing scenario.
func (c Cluster) Tolerable(s Scenario, name string) bool {
	// should not be applied with avoided scenarios, or it's own scenario
	rejects := append(s.Avoid, name)

	for _, active := range c.ActiveScenarios {
		for _, reject := range rejects {
			if reject == active {
				return false
			}
		}
	}
	return true
}

// Add applies the config to the cluster and records the scenarios name. Restrictions are not checked.
func (c *Cluster) Add(cfg Config, scenarioName string) {
	c.ActiveScenarios = append(c.ActiveScenarios, scenarioName)
	c.Config.Apply(cfg)
}

