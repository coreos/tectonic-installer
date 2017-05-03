package cluster

import (
	"sort"
)

func Constrain(base Config, scenarios Scenarios) (clusters []Config) {
	// sort scenarios descending from highest number of variants
	sort.Sort(scenarios)
	scenarios = sort.Reverse(scenarios)

	// contains a slice entry for each cluster required, with a map of scenarios
	clusters := []Config{}
	sPtrs := make([][]*Config, len(scenarios))
	for sName, s := range scenarios {
		vPtrs := make([]*Config, len(s.Variants))
		for vName, v := range s.Variants {
			// attempt to assign variant to existing cluster
			for _, c := range clusters {
				if c.CanApply(s, sName) {
					c.Apply(v)

					// update recording of applied scenarios
					c.ActiveScenarios = append(c.ActiveScenarios, sName)
					break
				}
			}
		}
	}
}

func canPlace (clusters []map[string]Config,  ) bool {

}
