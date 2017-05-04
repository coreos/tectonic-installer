package cluster

import (
	"sort"
)

func Constrain(base Config, scenarios Scenarios) (clusters []Config) {
	// sort scenarios descending from highest number of variants
	sort.Sort(scenarios)
	scenarios = sort.Reverse(scenarios)

	// contains a slice entry for each cluster required, with a map of scenarios
	clusters := new(Clusters)
	sPtrs := make([][]*Config, len(scenarios))
	for _, s := range scenarios {
		vPtrs := make([]*Config, len(s.Variants))
		for _, v := range s.Variants {
			// attempt to assign variant to existing cluster
			c := clusters.Assign(s)
			if c == nil {
				// create new cluster since no compatible ones exist
				c = &Cluster{
					Config: base,
				}
				clusters = append(clusters, c)
			}

			c.Add(v, s.Name)
		}
	}
}