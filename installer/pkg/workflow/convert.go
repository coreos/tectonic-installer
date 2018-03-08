package workflow

import (
	"encoding/json"
	"fmt"
	"io/ioutil"

	"github.com/coreos/tectonic-installer/installer/pkg/config"
)

// NewInitWorkflow creates new instances of the 'init' workflow,
// responsible for initializing a new cluster.
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
	if err := json.Unmarshal([]byte(data), &m.cluster); err != nil {
		return err
	}

	return nil
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
