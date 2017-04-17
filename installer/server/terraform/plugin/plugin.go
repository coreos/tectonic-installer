package plugin

import (
	"fmt"

	"github.com/hashicorp/terraform/helper/schema"
	"github.com/hashicorp/terraform/plugin"
	"github.com/hashicorp/terraform/terraform"
)

const (
	// Name describes the name of the plugin.
	Name = "tectonic"
)

// Serve serves a plugin. This function never returns and should be the final
// function called in the main function of the plugin.
func Serve() {
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: Provider,
	})
}

// Provider returns the ResourceProvider including all the available resources.
func Provider() terraform.ResourceProvider {
	return &schema.Provider{
		Schema: map[string]*schema.Schema{},
		ResourcesMap: map[string]*schema.Resource{
			resourceName("local_file"):      ResourceLocalFile(),
			resourceName("template_folder"): ResourceFolder(),
		},
	}
}

func resourceName(name string) string {
	return fmt.Sprintf("%s_%s", Name, name)
}
