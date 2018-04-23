package workflow

import (
	"encoding/json"
	"fmt"
	"io/ioutil"

	"github.com/coreos/tectonic-installer/installer/pkg/config"
)

func TF2YAML(configFilePath string) error {
	config, err := readTFVarsConfig(configFilePath)
	if err != nil {
		return err
	}
	return printYAMLConfig(*config)
}

func readTFVarsConfig(configFilePath string) (*config.Cluster, error) {
	data, err := ioutil.ReadFile(configFilePath)
	if err != nil {
		return nil, err
	}

	config := &config.Cluster{}

	if err := json.Unmarshal([]byte(data), config); err != nil {
		return nil, err
	}
	return config, nil
}

func printYAMLConfig(config config.Cluster) error {
	yaml, err := config.YAML()
	if err != nil {
		return err
	}

	fmt.Println(yaml)

	return nil
}
