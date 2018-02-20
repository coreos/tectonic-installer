package workflow

// NewDestroyWorkflow creates new instances of the 'destroy' workflow,
// responsible for running the actions required to remove resources
// of an existing cluster and clean up any remaining artefacts.
func NewDestroyWorkflow(clusterDir string) Workflow {
	return Workflow{
		metadata: metadata{clusterDir: clusterDir},
		steps: []Step{
			readClusterConfigStep,
			destroyJoinStep,
			destroyBootstrapStep,
			destroyAssetsStep,
		},
	}
}

func destroyAssetsStep(m *metadata) error {
	if !hasStateFile(m.clusterDir, assetsStep) {
		// there is no statefile, therefore nothing to destroy for this step
		return nil
	}
	templateDir, err := findTemplatesForStep(assetsStep)
	if err != nil {
		return err
	}
	return tfDestroy(m.clusterDir, assetsStep, templateDir)
}

func destroyBootstrapStep(m *metadata) error {
	if !hasStateFile(m.clusterDir, bootstrapStep) {
		// there is no statefile, therefore nothing to destroy for this step
		return nil
	}
	templateDir, err := findTemplatesForStep(bootstrapStep)
	if err != nil {
		return err
	}
	return tfDestroy(m.clusterDir, bootstrapStep, templateDir)
}

func destroyJoinStep(m *metadata) error {
	if !hasStateFile(m.clusterDir, joinStep) {
		// there is no statefile, therefore nothing to destroy for this step
		return nil
	}
	templateDir, err := findTemplatesForStep(joinStep)
	if err != nil {
		return err
	}
	return tfDestroy(m.clusterDir, joinStep, templateDir)
}
