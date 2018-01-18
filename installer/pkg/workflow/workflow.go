package workflow

import "log"

// Workflow is a high-level representation
// of a set of actions performed in a predictable order
type Workflow interface {
	Execute() error
}

type Metadata map[string]interface{}

type Step interface {
	Execute(*Metadata) error
}

// Context represents the state of a workflow
type WorkflowType struct {
	metadata Metadata
	steps    []Step
}

func (w WorkflowType) Execute() error {
	var stepError error
	for _, oneStep := range w.steps {
		stepError = oneStep.Execute(&w.metadata)
		if stepError != nil {
			log.Fatal(stepError) // TODO: actually do proper error handling
		}
	}
	return nil
}

func (m *Metadata) SetValue(key string, value interface{}) error {
	(*m)[key] = value
	return nil
}

func (m *Metadata) GetValue(key string) interface{} {
	value := (*m)[key]
	return value
}