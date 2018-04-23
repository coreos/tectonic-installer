package workflow

import (
	"fmt"
	"os"
	"path/filepath"
)

func terraformExec(stateDir string, args ...string) error {
	// Create an executor
	ex, err := newExecutor()
	if err != nil {
		return fmt.Errorf("Could not create Terraform executor: %s", err)
	}

	err = ex.execute(stateDir, args...)
	if err != nil {
		return fmt.Errorf("Failed to run Terraform: %s", err)
	}
	return nil
}

func tfApply(stateDir string, state string, templateDir string, extraArgs ...string) error {
	defaultArgs := []string{
		"apply",
		"-auto-approve",
		fmt.Sprintf("-state=%s.tfstate", state),
	}
	extraArgs = append(extraArgs, templateDir)
	args := append(defaultArgs, extraArgs...)
	return terraformExec(stateDir, args...)
}

func tfDestroy(clusterDir, state, templateDir string, extraArgs ...string) error {
	defaultArgs := []string{
		"destroy",
		"-force",
		fmt.Sprintf("-state=%s.tfstate", state),
	}
	extraArgs = append(extraArgs, templateDir)
	args := append(defaultArgs, extraArgs...)
	return terraformExec(clusterDir, args...)
}

func tfInit(clusterDir, templateDir string) error {
	return terraformExec(clusterDir, "init", templateDir)
}

func hasStateFile(stateDir string, stateName string) bool {
	stepStateFile := filepath.Join(stateDir, fmt.Sprintf("%s.tfstate", stateName))
	_, err := os.Stat(stepStateFile)
	return !os.IsNotExist(err)
}

// returns the directory containing templates for a given step. If platform is
// specified, it looks for a subdirectory with platform first, falling back if
// there are no platform-specific templates for that step
func findStepTemplates(stepName, platform string) (string, error) {
	base, err := baseLocation()
	if err != nil {
		return "", fmt.Errorf("error looking up step %s templates: %v", stepName, err)
	}
	for _, path := range []string{
		filepath.Join(base, stepsBaseDir, stepName, platform),
		filepath.Join(base, stepsBaseDir, stepName)} {

		stat, err := os.Stat(path)
		if err != nil {
			if os.IsNotExist(err) {
				continue
			}
			return "", fmt.Errorf("invalid path for '%s' templates: %s", base, err)
		}
		if !stat.IsDir() {
			return "", fmt.Errorf("invalid path for '%s' templates", base)
		}
		return path, nil
	}
	return "", os.ErrNotExist
}
