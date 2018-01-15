package config

import (
	"io/ioutil"

	"gopkg.in/yaml.v2"
)

func Parse(data string) (*Config, error) {
	config := &Config{}

	err := yaml.Unmarshal([]byte(data), config)
	if err != nil {
		return nil, err
	}

	return config, nil
}

func ParseFile(path string) (*Config, error) {
	dat, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}

	return Parse(string(dat))
}
