package plugin

import (
	"fmt"
	"testing"

	"io/ioutil"

	r "github.com/hashicorp/terraform/helper/resource"
	"github.com/hashicorp/terraform/helper/schema"
	"github.com/hashicorp/terraform/terraform"
)

func TestLocalFile_Basic(t *testing.T) {
	var cases = []struct {
		path    string
		content string
		config  string
	}{
		{
			"localfile",
			"This is some content",
			`resource "` + Name + `_localfile" "file" {
         content     = "This is some content"
         destination = "localfile"
      }`,
		},
	}

	for _, tt := range cases {
		r.UnitTest(t, r.TestCase{
			Providers: map[string]terraform.ResourceProvider{
				Name: &schema.Provider{
					Schema: map[string]*schema.Schema{},
					ResourcesMap: map[string]*schema.Resource{
						resourceName("localfile"): ResourceLocalFile(),
					},
				},
			},
			Steps: []r.TestStep{
				{
					Config: tt.config,
					Check: func(s *terraform.State) error {
						content, err := ioutil.ReadFile(tt.path)
						if err != nil {
							return fmt.Errorf("config:\n%s\n,got: %s\n", tt.config, err)
						}
						if string(content) != tt.content {
							return fmt.Errorf("config:\n%s\ngot:\n%s\nwant:\n%s\n", tt.config, content, tt.content)
						}
						return nil
					},
				},
			},
		})
	}
}
