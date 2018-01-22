package workflow

import (
	"log"
	"os"
	"os/exec"

	"github.com/coreos/tectonic-installer/installer/pkg/tectonic"
)

func NewDestroyWorkflow(userConfig Metadata) Workflow {
	return WorkflowType{
		metadata: userConfig,
		steps: []Step{
			terraformPrepareStep{},
			terraformInitStep{},
			terraformDestroyStep{},
		},
	}
}

type terraformDestroyStep struct{}

func (s terraformDestroyStep) Execute(m *Metadata) error {
	bp := (m.GetValue("build_path")).(string)
	if bp == "" {
		log.Fatalf("Invalid build location - cannot destroy.")
	}
	log.Printf("Destroying cluster from %s...", m.GetValue("build_path").(string))
	tfDestroy := exec.Command("terraform", "destroy", "-force", tectonic.FindTemplatesForType("aws")) // TODO: get from cluster config
	tfDestroy.Dir = bp
	tfDestroy.Stdin = os.Stdin
	tfDestroy.Stdout = os.Stdout
	tfDestroy.Stderr = os.Stderr
	err := tfDestroy.Run()
	if err != nil {
		return err
	}
	return nil
}
