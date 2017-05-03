package cluster

import "path/filepath"

// Scenario contains a set of variants which are tests mutually exclusively.
type Scenario struct {
	// Variants are cluster configurations that are applied separately from each other.
	Variants []Config

	// Avoid contains scenarios which this scenario should avoid.
	Avoid    []string
}

// Scenarios represented in a set
type Scenarios map[string]Scenario

func (s Scenarios) Match(pattern string) ([]Scenario, error) {
	scenarios := []Scenario{}
	for name, val := range s {
		if match, err := filepath.Match(pattern, name); err != nil {
			return nil, err
		} else if match {
			scenarios = append(scenarios, val)
		}
	}
	return scenarios, nil
}

// OrderedScenarios implements the sort interface.
type OrderedScenarios []Scenario

func (s OrderedScenarios) Len() int {
	return len(s)
}

func (s OrderedScenarios) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}

// Less returns if i has less variants than j
func (s OrderedScenarios) Less(i, j int) bool {
	return len(s[i].Variants) < len(s[j].Variants)
}