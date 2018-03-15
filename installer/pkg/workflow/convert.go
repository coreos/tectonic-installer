package workflow

import (
	"encoding/json"
	"fmt"
	"io/ioutil"

	"github.com/coreos/tectonic-installer/installer/pkg/config"
)

// NewConvertWorkflow creates new instances of the 'convert' workflow,
// responsible for converting an old cluster config.
func NewConvertWorkflow(configFilePath string) Workflow {
	return Workflow{
		metadata: metadata{configFilePath: configFilePath},
		steps: []Step{
			readTFVarsConfigStep,
			generateYAMLConfigStep,
		},
	}
}

func readTFVarsConfigStep(m *metadata) error {
	data, err := ioutil.ReadFile(m.configFilePath)
	if err != nil {
		return err
	}

	m.cluster = config.Cluster{}

	return json.Unmarshal([]byte(data), &m.cluster)
}

func generateYAMLConfigStep(m *metadata) error {
	config := config.Config{
		Clusters: []config.Cluster{m.cluster},
	}

	yaml, err := config.YAML()
	if err != nil {
		return err
	}

	fmt.Println(yaml)

	return nil
}
