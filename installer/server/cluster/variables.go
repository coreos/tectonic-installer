package cluster

import (
	"github.com/fatih/structs"
)

func (c *Config) Variables() map[string]interface{} {
	s := structs.New(c)
	s.TagName = "hcl"
	return s.Map()
}
