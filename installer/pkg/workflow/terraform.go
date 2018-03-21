package workflow

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/coreos/tectonic-installer/installer/pkg/terraform"
)

func terraformExec(clusterDir string, args ...string) error {
	// Get the path of the currently running binary
	executionPath, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		return err
	}

	// Create an executor
	ex, err := terraform.NewExecutor(executionPath)
	if err != nil {
		fmt.Printf("Could not create Terraform executor")
		return err
	}

	err = ex.Execute(clusterDir, args...)
	if err != nil {
		fmt.Printf("Failed to run Terraform: %s", err)
		return err
	}
	return nil
}

func tfApply(clusterDir, state, templateDir string) error {
	return terraformExec(clusterDir, "apply", "-auto-approve", fmt.Sprintf("-state=%s.tfstate", state), templateDir)
}

func tfDestroy(clusterDir, state, templateDir string) error {
	return terraformExec(clusterDir, "destroy", "-force", fmt.Sprintf("-state=%s.tfstate", state), templateDir)
}

func tfInit(clusterDir, templateDir string) error {
	return terraformExec(clusterDir, "init", templateDir)
}

func hasStateFile(stateDir string, stateName string) bool {
	stepStateFile := filepath.Join(stateDir, fmt.Sprintf("%s.tfstate", stateName))
	_, err := os.Stat(stepStateFile)
	return !os.IsNotExist(err)
}
