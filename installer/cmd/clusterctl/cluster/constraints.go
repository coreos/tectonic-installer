package cluster

import (
	"math/rand"
	"sort"
)

func Constrain(base *Config, scenarios Scenarios) (clusters Clusters) {
	// sort scenarios descending from highest number of variants
	sort.Sort(scenarios)
	scenarios = sort.Reverse(scenarios)

	// contains a slice entry for each cluster required, with a map of scenarios
	sPtrs := make([][]*Config, len(scenarios))
	for sNum, s := range scenarios {
		vPtrs := make([]*Config, len(s.Variants))
		for vNum, v := range s.Variants {
			// attempt to assign variant to existing cluster
			c := clusters.Assign(s)
			if c == nil {
				// create new cluster since no compatible ones exist
				c = &Cluster{
					Config: base,
				}
				clusters = append(clusters, c)
			}
			c.Add(s, v)

			// add to slice to allow randomization
			vPtrs[vNum] = v
		}
		sPtrs[sNum] = vPtrs
	}
	shuffle(sPtrs)
	return
}

func shuffle(s [][]*Config) {
	for _, variants := range s {
		// randomize variants within a scenario
		for i, v := range rand.Perm(len(variants)) {
			*variants[i] = *variants[v]
		}
	}
}
