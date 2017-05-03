package cluster

import "path/filepath"

// Spec defines various cluster configurations that can be deployed using clusterctl.
type Spec struct {
	Config
	Scenarios
}

// Build creates clusters for the named scenarios given. If no scenarios or an empty string is given the default will be used.
func (spec *Spec) Build(patterns ...string) (clusters []Config, err error) {
	scenarioNames := make(map[string]bool, len(patterns))
	for _, n := range patterns {
		scenarioNames[n] = true
	}

	// use all if none given
	if len(scenarioNames) == 0 {
		scenarioNames["*"] = true
	}

	scenarios := []Scenario{}
	for s := range scenarioNames {
		matchedScenarios, err := spec.Scenarios.Match(s)
		if err != nil {
			return nil, err
		}
		scenarios = append(scenarios, matchedScenarios)
	}

	return Constrain(spec.Config, scenarios), nil
}


