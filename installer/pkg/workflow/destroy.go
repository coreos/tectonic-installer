package workflow

import (
	"log"
	"os"

	"github.com/coreos/tectonic-installer/installer/pkg/tectonic"
)

// NewDestroyWorkflow creates new instances of the 'destroy' workflow,
// responsible for running the actions required to remove resources
// of an existing cluster and clean up any remaining artefacts.
func NewDestroyWorkflow(buildPath string) Workflow {
	pathStat, err := os.Stat(buildPath)
	// TODO: add deeper checking of the path for having cluster state
	if os.IsNotExist(err) || !pathStat.IsDir() {
		log.Fatalf("Provided path %s is not valid cluster state location.", buildPath)
	} else if err != nil {
		log.Fatalf("%v encountered while validating build location.", err)
	}

	// TODO: Discrimitate by config provider. if platform is aws:
	return simpleWorkflow{
		metadata: metadata{
			statePath: buildPath,
		},
		steps: []Step{
			terraformPrepareStep,
			joiningDestroyStep,
			bootstrapDestroyStep,
			ignitionDestroyStep,
			assetsDestroyStep,
			tlsDestroyStep,
		},
	}

	//return simpleWorkflow{
	//	metadata: metadata{
	//		statePath: buildPath,
	//	},
	//	steps: []Step{
	//		terraformPrepareStep,
	//		terraformInitStep,
	//		terraformDestroyStep,
	//	},
	//}
}

//func terraformDestroyStep(m *metadata) error {
//	if m.statePath == "" {
//		log.Fatalf("Invalid build location - cannot destroy.")
//	}
//	log.Printf("Destroying cluster from %s...", m.statePath)
//	err := tfDestroy(m.statePath, "state", tectonic.FindTemplatesForType("aws"))
//	if err != nil {
//		return err
//	}
//	return nil
//}

func joiningDestroyStep(m *metadata) error {
	err := tfDestroy(m.statePath, "joining", tectonic.FindTemplatesForStep("joining"))
	if err != nil {
		return err
	}
	return nil
}

func bootstrapDestroyStep(m *metadata) error {
	err := tfDestroy(m.statePath, "bootstrap", tectonic.FindTemplatesForStep("bootstrap"))
	if err != nil {
		return err
	}
	return nil
}

func ignitionDestroyStep(m *metadata) error {
	err := tfDestroy(m.statePath, "ignition", tectonic.FindTemplatesForStep("ignition"))
	if err != nil {
		return err
	}
	return nil
}

func assetsDestroyStep(m *metadata) error {
	err := tfDestroy(m.statePath, "assets", tectonic.FindTemplatesForStep("assets"))
	if err != nil {
		return err
	}
	return nil
}

func tlsDestroyStep(m *metadata) error {
	err := tfDestroy(m.statePath, "tls", tectonic.FindTemplatesForStep("tls"))
	if err != nil {
		return err
	}
	return nil
}
