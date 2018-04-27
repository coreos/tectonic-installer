package workflow

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	log "github.com/Sirupsen/logrus"
	"github.com/coreos/tectonic-installer/installer/pkg/config"
	configgenerator "github.com/coreos/tectonic-installer/installer/pkg/config-generator"
	yaml "gopkg.in/yaml.v2"
)

const (
	stepsBaseDir               = "steps"
	assetsStep                 = "assets"
	topologyStep               = "topology"
	tncDNSStep                 = "tnc_dns"
	bootstrapOn                = "-var=tectonic_aws_bootstrap=true"
	bootstrapOff               = "-var=tectonic_aws_bootstrap=false"
	bootstrapStep              = "bootstrap"
	etcdStep                   = "etcd"
	joinMastersStep            = "joining_masters"
	joinWorkersStep            = "joining_workers"
	configFileName             = "config.yaml"
	internalFileName           = "internal.yaml"
	terraformVariablesFileName = "terraform.tfvars"
)

// Cluster models the cluster info within a workspace
// and enables running actions over the given cluster
type Cluster struct {
	workspace string
	config    config.Cluster
	platform  string
}

// InitWorkspace generates, if successful, a workspace folder with the config.yaml
func InitWorkspace(sourceConfigFilePath, workspaceName string) error {
	if sourceConfigFilePath == "" {
		errors.New("no cluster sourceConfigFilePath given for instantiating new cluster")
	}
	if workspaceName == "" {
		errors.New("no cluster sourceConfigFilePath given for instantiating new cluster")
	}

	// generate workspace folder
	dir, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("Failed to get current directory because: %s", err)
	}
	workspace := filepath.Join(dir, workspaceName)

	if stat, err := os.Stat(workspace); err == nil && stat.IsDir() {
		return fmt.Errorf("workspace directory already exists at %s", workspace)
	}

	if err := os.MkdirAll(workspace, os.ModeDir|0755); err != nil {
		return fmt.Errorf("failed to create workspace directory at %s", workspace)
	}

	// put config file under the workspace folder
	configFilePath := filepath.Join(workspace, configFileName)
	if err := copyFile(sourceConfigFilePath, configFilePath); err != nil {
		return fmt.Errorf("failed to create cluster config at %s: %v", workspace, err)
	}

	// generate the internal config file under the workspace folder
	return buildInternalConfig(workspace)
}

// NewCluster creates a cluster struct from a workspace
// It ensures cluster.config and the tfvars file are always up to date with config.yaml
func NewCluster(workspace string) (*Cluster, error) {
	if workspace == "" {
		errors.New("no workspace dir given for new cluster")
	}

	config, err := readClusterConfig(workspace)
	if err != nil {
		return nil, fmt.Errorf("failed to read cluster config when refreshing it: %v", err)
	}

	c := Cluster{
		config:    *config,
		platform:  strings.ToLower(config.Platform),
		workspace: workspace,
	}

	if err := c.generateTerraformVariables(); err != nil {
		return nil, fmt.Errorf("failed to generate terraform variables when creating new cluster: %v", err)
	}
	return &c, nil
}

// Assets generates, if successful, the cluster assets
func (c Cluster) Assets() error {
	if err := c.generateClusterConfigMaps(); err != nil {
		return err
	}
	if err := c.runInstallStep(assetsStep); err != nil {
		return err
	}
	return c.generateIgnConfig()
}

// Bootstrap runs, if successful, the steps to bootstrap a single node cluster
func (c Cluster) Bootstrap() error {
	if err := c.runInstallStep(topologyStep); err != nil {
		return err
	}
	if err := c.createTNCCNAME(); err != nil {
		return err
	}
	if err := c.runInstallStep(bootstrapStep); err != nil {
		return err
	}
	if err := c.createTNCARecord(); err != nil {
		return err
	}
	return c.runInstallStep(etcdStep)
}

// Scale runs, if successful, the steps to scale a cluster
func (c Cluster) Scale() error {
	if err := c.importAutoScalingGroup(); err != nil {
		return err
	}
	if err := c.runInstallStep(joinMastersStep); err != nil {
		return err
	}
	return c.runInstallStep(joinWorkersStep)
}

// Install runs, if successful, the steps to install a cluster
func (c Cluster) Install() error {
	if err := c.Assets(); err != nil {
		return err
	}
	if err := c.Bootstrap(); err != nil {
		return err
	}
	return c.Scale()
}

// Destroy runs, if successful, the steps to destroy a cluster
func (c Cluster) Destroy() error {
	if err := c.runDestroyStep(joinMastersStep); err != nil {
		return err
	}
	if err := c.runDestroyStep(joinWorkersStep); err != nil {
		return err
	}
	if err := c.runDestroyStep(etcdStep); err != nil {
		return err
	}
	if err := c.runDestroyStep(bootstrapStep); err != nil {
		return err
	}
	if err := c.runDestroyStep(tncDNSStep, []string{bootstrapOff}...); err != nil {
		return err
	}
	if err := c.runDestroyStep(topologyStep); err != nil {
		return err
	}
	return c.runDestroyStep(assetsStep)
}

func (c Cluster) runInstallStep(step string, extraArgs ...string) error {
	templateDir, err := findStepTemplates(step, c.platform)
	if err != nil {
		return err
	}
	if err := tfInit(c.workspace, templateDir); err != nil {
		return err
	}
	return tfApply(c.workspace, step, templateDir, extraArgs...)
}

func (c Cluster) runDestroyStep(step string, extraArgs ...string) error {
	if !hasStateFile(c.workspace, step) {
		log.Warningf("there is no statefile, therefore nothing to destroy for the step %s within %s", step, c.workspace)
		return nil
	}
	templateDir, err := findStepTemplates(step, c.config.Platform)
	if err != nil {
		return err
	}

	return tfDestroy(c.workspace, step, templateDir, extraArgs...)
}

func (c Cluster) generateClusterConfigMaps() error {
	configGenerator := configgenerator.New(c.config)
	return configGenerator.GenerateClusterConfigMaps(c.workspace)
}

func (c Cluster) generateIgnConfig() error {
	configGenerator := configgenerator.New(c.config)
	return configGenerator.GenerateIgnConfig(c.workspace)
}

func (c Cluster) generateTerraformVariables() error {
	vars, err := c.config.TFVars()
	if err != nil {
		return err
	}

	terraformVariablesFilePath := filepath.Join(c.workspace, terraformVariablesFileName)
	return writeFile(terraformVariablesFilePath, vars)
}

func (c Cluster) createTNCCNAME() error {
	if !c.clusterIsBootstrapped() {
		return c.runInstallStep(tncDNSStep, []string{bootstrapOn}...)
	}
	return nil
}

func (c Cluster) clusterIsBootstrapped() bool {
	return hasStateFile(c.workspace, topologyStep) &&
		hasStateFile(c.workspace, bootstrapStep) &&
		hasStateFile(c.workspace, tncDNSStep)
}

func (c Cluster) createTNCARecord() error {
	return c.runInstallStep(tncDNSStep, []string{bootstrapOff}...)
}

func (c Cluster) importAutoScalingGroup() error {
	templatesPath, err := findStepTemplates(joinMastersStep, c.platform)
	if err != nil {
		return err
	}
	return terraformExec(
		c.workspace,
		"import",
		fmt.Sprintf("-state=%s.tfstate", joinMastersStep),
		fmt.Sprintf("-config=%s", templatesPath),
		"aws_autoscaling_group.masters",
		fmt.Sprintf("%s-masters", c.config.Name))
}

// readClusterConfig builds a config.Cluster from a workspace
// it's not allowed to modify cluster.Config because we only
// want that to happen atomically with generateTerraformVariables
func readClusterConfig(workspace string) (*config.Cluster, error) {
	if workspace == "" {
		errors.New("no workspace dir given for reading config")
	}
	configFilePath := filepath.Join(workspace, configFileName)
	internalFilePath := filepath.Join(workspace, internalFileName)

	clusterConfig, err := parseClusterConfig(configFilePath, internalFilePath)
	if err != nil {
		return nil, fmt.Errorf("failed to parse cluster config when reading it: %v", err)
	}

	if errs := clusterConfig.Validate(); len(errs) != 0 {
		log.Errorf("Found %d errors in the cluster definition:", len(errs))
		for i, err := range errs {
			log.Errorf("error %d: %v", i+1, err)
		}
		return nil, fmt.Errorf("found %d cluster definition errors", len(errs))
	}

	return clusterConfig, nil
}

func parseClusterConfig(configFilePath string, internalFilePath string) (*config.Cluster, error) {
	cfg, err := config.ParseConfigFile(configFilePath)
	if err != nil {
		return nil, fmt.Errorf("%s is not a valid config file: %s", configFilePath, err)
	}

	if internalFilePath != "" {
		internal, err := config.ParseInternalFile(internalFilePath)
		if err != nil {
			return nil, fmt.Errorf("%s is not a valid internal file: %s", internalFilePath, err)
		}
		cfg.Internal = *internal
	}

	return cfg, nil
}

func buildInternalConfig(workspace string) error {
	if workspace == "" {
		return errors.New("no workspace dir given for building internal config")
	}

	// fill the internal struct
	clusterID, err := configgenerator.GenerateClusterID(16)
	if err != nil {
		return err
	}
	internalCfg := config.Internal{
		ClusterID: clusterID,
	}

	// store the content
	yamlContent, err := yaml.Marshal(internalCfg)
	internalFileContent := []byte("# Do not touch, auto-generated\n")
	internalFileContent = append(internalFileContent, yamlContent...)
	if err != nil {
		return err
	}
	return writeFile(filepath.Join(workspace, internalFileName), string(internalFileContent))
}
