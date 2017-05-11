package cluster

import (
	"testing"

	"github.com/coreos/tectonic-installer/installer/server"
)

// TestClusterTolerable verifies that cluster constraints are correctly applied.
func TestClusterTolerable(t *testing.T) {
	s := &Scenario{
		Name: "self-hosted",
		Variants: []*Config{
			{
				Name: "self-hosted-enabled",
				TerraformApplyHandlerInput: server.TerraformApplyHandlerInput{
					Variables: map[string]interface{}{
						"tectonic_experimental": true,
					},
				},
			},
		},
	}
	c := new(Cluster)

	// empty cluster
	if !c.Tolerable(s) {
		t.Fatal("all scenarios should be tolerable on empty clusters")
	}
	if c.Add(s, "self-hosted-enabled") != nil {
		t.Fatal("should be able to add to empty cluster")
	}

	// scenario already added
	if c.Tolerable(s) {
		t.Fatal("should not be able to add a scenario to a cluster twice")
	}
}

// TestClusterAssign verifies scenarios are assigned to reasonable clusters.
func TestClusterAssign(t *testing.T) {
	clusterA, clusterB, clusterC := NewCluster("A"), NewCluster("B"), NewCluster("C")

	// cluster A has 2 items
	clusterA.Add(&Scenario{
		Name: "scenario1",
		Variants: []*Config{
			{
				Name: "variant1",
			},
		},
	}, "variant1")
	clusterA.Add(&Scenario{
		Name: "scenario2",
		Variants: []*Config{
			{
				Name: "variant1",
			},
		},
	}, "variant1")

	// cluster B is empty

	// cluster C has 3 items
	clusterC.Add(&Scenario{
		Name: "scenario1",
		Variants: []*Config{
			{
				Name: "variant2",
			},
		},
	}, "variant2")
	clusterC.Add(&Scenario{
		Name: "scenario2",
		Variants: []*Config{
			{
				Name: "variant2",
			},
		},
	}, "variant2")
	clusterC.Add(&Scenario{
		Name: "scenario3",
		Variants: []*Config{
			{
				Name: "variant1",
			},
		},
	}, "variant1")

	clusters := Clusters{clusterA, clusterB, clusterC}
	assigned := clusters.Assign(&Scenario{
		Name: "scenario4",
		Variants: []*Config{
			{
				Name: "variant1",
			},
		},
	})

	maxScenarios := 0
	if assigned == nil {
		t.Fatal("failed to assign to a cluster")
	} else if len(assigned.scenarios) > maxScenarios {
		t.Fatalf("should have minimized to %d (had %d)", maxScenarios, assigned)
	}
}

// TestClusterNoAssign verifies scenarios don't get assigned in invalid situations.
func TestClusterNoAssign(t *testing.T) {
	clusters := Clusters{}
	assigned := clusters.Assign(&Scenario{
		Name: "scenario4",
		Variants: []*Config{
			{
				Name: "variant1",
			},
		},
	})

	if assigned != nil {
		t.Fatal("cannot assign to empty list of clusters")
	}

	c := NewCluster("single")
	c.Add(&Scenario{
		Name: "scenario3",
		Variants: []*Config{
			{
				Name: "variant1",
			},
		},
	}, "variant1")

	assigned = clusters.Assign(&Scenario{
		Name: "scenario3",
		Variants: []*Config{
			{
				Name: "variant2",
			},
		},
	})
	if assigned != nil {
		t.Fatal("should not be able to assign cluster with conflict")
	}
}
