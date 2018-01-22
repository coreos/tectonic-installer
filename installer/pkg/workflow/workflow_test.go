package workflow

import (
	"errors"
	"testing"
)

type test1Step struct{}

func (t test1Step) Execute(m *Metadata) error {
	return nil
}

type test2Step struct{}

func (t test2Step) Execute(m *Metadata) error {
	return nil
}

type test3Step struct{}

func (t test3Step) Execute(m *Metadata) error {
	return errors.New("Boom! Step failed.")
}

func TestWorkflowTypeExecute(t *testing.T) {
	m := Metadata{
		"var_file":     "./fixtures/test.tfvars",
		"cluster_name": "test-cluster",
	}

	testCases := []struct {
		test          string
		steps         []Step
		m             Metadata
		expectedError bool
	}{
		{
			test:          "All steps succeed",
			steps:         []Step{test1Step{}, test2Step{}},
			m:             m,
			expectedError: false,
		},
		{
			test:          "At least one step fails",
			steps:         []Step{test1Step{}, test2Step{}, test3Step{}},
			m:             m,
			expectedError: true,
		},
	}

	for _, tc := range testCases {
		wf := WorkflowType{
			metadata: tc.m,
			steps:    tc.steps,
		}
		err := wf.Execute()
		if (err != nil) != tc.expectedError {
			t.Errorf("Test case %s: WorkflowType.Execute() expected error: %v, got: %v", tc.test, tc.expectedError, (err != nil))
		}
	}
}
