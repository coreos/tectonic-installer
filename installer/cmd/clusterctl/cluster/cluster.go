package cluster

import (
	"errors"
	"fmt"
	"sort"
)

// NewCluster returns a cluster with the given name.
func NewCluster(name string) *Cluster {
	return &Cluster{
		Config: &Config{
			Name: name,
		},
	}
}

// Cluster represents a Tectonic instance.
type Cluster struct {
	// Config describes the parameters the cluster is to be provisioned with.
	*Config

	// Variants that will be applied to the cluster, key is the scenario the variant is from.
	Scenarios map[string]*Config
}

// Tolerable validates whether scenario s with name n can be applied to this cluster. A scenario may not be applied
// because another variant from the scenario has already been applied or there's a constraint with an existing scenario.
func (c Cluster) Tolerable(s *Scenario) bool {
	// should not be applied with avoided scenarios, or it's own scenario
	rejects := append(s.Avoid, s.Name)

	for cur := range c.Scenarios {
		for _, reject := range rejects {
			if reject == cur {
				return false
			}
		}
	}
	return true
}

// Add applies the config to the cluster and records the scenarios name. Restrictions are not checked.
func (c *Cluster) Add(scenario *Scenario, variantName string) error {
	if c.Scenarios == nil {
		c.Scenarios = map[string]*Config{}
	}

	if scenario != nil {
		for _, variant := range scenario.Variants {
			if variant.Name == variantName {
				c.Scenarios[scenario.Name] = variant
				return nil
			}
		}
		return fmt.Errorf("could not find variant '%s' in scenario", variantName)
	}
	return errors.New("could not add: passed scenario was nil")
}

// Clusters are sorted by least number of scenarios.
type Clusters []*Cluster

// Assign returns a cluster which can run the given scenario. Nil is returned if no suitable cluster exists.
func (clusters Clusters) Assign(s *Scenario) *Cluster {
	sort.Sort(clusters)
	for _, c := range clusters {
		if c.Tolerable(s) {
			return c
		}
	}
	return nil
}

func (c Clusters) Len() int {
	return len(c)
}

func (c Clusters) Swap(i, j int) {
	c[i], c[j] = c[j], c[i]
}

// Less returns true if the other item has more scenarios
func (c Clusters) Less(i, j int) bool {
	return len(c[i].Scenarios) < len(c[j].Scenarios)
}
