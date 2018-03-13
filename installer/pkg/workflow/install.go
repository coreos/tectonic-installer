package workflow

// NewInstallFullWorkflow creates new instances of the 'install' workflow,
// responsible for running the actions necessary to install a new cluster.
func NewInstallFullWorkflow(clusterDir string) Workflow {
	return Workflow{
		metadata: metadata{clusterDir: clusterDir},
		steps: []Step{
			readClusterConfigStep,
			installAssetsStep,
			generateClusterConfigStep,
			installBootstrapStep,
			installJoinStep,
			installBootstrapTearDownStep,
		},
	}
}

// NewInstallAssetsWorkflow creates new instances of the 'assets' workflow,
// responsible for running the actions necessary to generate cluster assets.
func NewInstallAssetsWorkflow(clusterDir string) Workflow {
	return Workflow{
		metadata: metadata{clusterDir: clusterDir},
		steps: []Step{
			readClusterConfigStep,
			installAssetsStep,
			generateClusterConfigStep,
		},
	}
}

// NewInstallBootstrapWorkflow creates new instances of the 'bootstrap' workflow,
// responsible for running the actions necessary to generate a single bootstrap machine cluster.
func NewInstallBootstrapWorkflow(clusterDir string) Workflow {
	return Workflow{
		metadata: metadata{clusterDir: clusterDir},
		steps: []Step{
			readClusterConfigStep,
			installBootstrapStep,
		},
	}
}

// NewInstallJoinWorkflow creates new instances of the 'join' workflow,
// responsible for running the actions necessary to scale the machines of the cluster.
func NewInstallJoinWorkflow(clusterDir string) Workflow {
	return Workflow{
		metadata: metadata{clusterDir: clusterDir},
		steps: []Step{
			readClusterConfigStep,
			installJoinStep,
			installBootstrapTearDownStep,
		},
	}
}

func installAssetsStep(m *metadata) error {
	return runInstallStep(m.clusterDir, assetsStep)
}

func installBootstrapStep(m *metadata) error {
	if err := runInstallStep(m.clusterDir, bootstrapStep); err != nil {
		return err
	}

	return waitForTNC(m, 1)
}

func installJoinStep(m *metadata) error {
	// TODO: import will fail after a first run, error is ignored for now
	importAutoScalingGroup(m, joinStep, "masters")
	importAutoScalingGroup(m, joinStep, "workers")

	return runInstallStep(m.clusterDir, joinStep)
}

func installBootstrapTearDownStep(m *metadata) error {
	if err := waitForTNC(m, m.cluster.Master.Count+1); err != nil {
		return err
	}
	importAutoScalingGroup(m, bootstrapTearDownStep, "master-bootstrap")
	return runInstallStep(m.clusterDir, bootstrapTearDownStep)
}

func runInstallStep(clusterDir, step string) error {
	templateDir, err := findTemplates(step)
	if err != nil {
		return err
	}
	if err := tfInit(clusterDir, templateDir); err != nil {
		return err
	}

	return tfApply(clusterDir, step, templateDir)
}
