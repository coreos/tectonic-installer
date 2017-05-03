package cluster

// Cluster represents a Tectonic instance.
type Cluster struct {
	// ActiveScenarios are the scenarios that are currently being applied to the cluster
	ActiveScenarios []string
}

// CanApply validates whether scenario s with name n can be applied to this cluster. A scenario may not be applied
// because another variant from the scenario has already been applied or there's a constraint with an existing scenario.
func (c Cluster) CanApply(s Scenario, name string) bool {
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

// Clusters represent a grouping of clusters.
type Clusters []Config

