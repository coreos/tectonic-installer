package configgenerator

import (
	"bufio"
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"text/template"

	ctconfig "github.com/coreos/container-linux-config-transpiler/config"
	ctconfigtypes "github.com/coreos/container-linux-config-transpiler/config/types"
	ignconfig "github.com/coreos/ignition/config/v2_1"
	ignconfigtypes "github.com/coreos/ignition/config/v2_1/types"
	"github.com/coreos/tectonic-installer/installer/pkg/config"
	"gopkg.in/yaml.v2"
)

var (
	ignVersion   = "2.1.0"
	ignFilesPath = map[string]string{
		"master": config.IgnitionMaster,
		"worker": config.IgnitionWorker,
		"etcd":   config.IgnitionEtcd,
	}
)

const (
	kubeconfigKubeletPath = "generated/auth/kubeconfig-kubelet"
	// IgnTemplatesBaseDir is the base dir in the build tree for the ign yaml templates
	IgnTemplatesBaseDir  = "ign-templates"
	filesTemplatesFolder = "files"
	unitsTemplatesFolder = "units"
)

// bootstrapConfig contains the ignition config to populate the templates
type bootstrapConfig struct {
	HyperkubeImage        string
	KubecorerendererImage string
	AssetsS3Location      string
	AwscliImage           string
	CloudProvider         string
	ClusterDNSIP          string
	BootkubeImage         string
}

type ignTemplates struct {
	filesPaths []string
	unitsPaths []string
}

func (c ConfigGenerator) poolToRoleMap() map[string]string {
	poolToRole := make(map[string]string)
	// assume no roles can share pools
	for _, n := range c.Master.NodePools {
		poolToRole[n] = "master"
	}
	for _, n := range c.Worker.NodePools {
		poolToRole[n] = "worker"
	}
	for _, n := range c.Etcd.NodePools {
		poolToRole[n] = "etcd"
	}
	return poolToRole
}

// GenerateIgnConfig generates, if successful, files with the ign config for each role.
func (c ConfigGenerator) GenerateIgnConfig(clusterDir string, ignTemplatesPath string) error {
	if err := c.generateIgnPoolsConfig(clusterDir); err != nil {
		return err
	}
	return c.generateIgnBootstrapConfig(clusterDir, ignTemplatesPath)
}

func (c ConfigGenerator) generateIgnPoolsConfig(clusterDir string) error {
	poolToRole := c.poolToRoleMap()
	for _, p := range c.NodePools {
		ignFile := p.IgnitionFile
		ignCfg, err := parseIgnFile(ignFile)
		if err != nil {
			return fmt.Errorf("failed to GenerateIgnConfig for pool %s and file %s: %v", p.Name, p.IgnitionFile, err)
		}
		role := poolToRole[p.Name]
		// TODO(alberto): Append block need to be different for each etcd node.
		// add loop over count if role is etcd
		c.embedAppendBlock(ignCfg, role)
		if role != "etcd" {
			kubeconfigKubeletContent, err := getKubeconfigKubeletContent(clusterDir)
			if err != nil {
				return err
			}
			c.embedKubeconfigKubeletBlock(ignCfg, kubeconfigKubeletContent)
		}

		fileTargetPath := filepath.Join(clusterDir, ignFilesPath[role])
		if err = ignCfgToFile(*ignCfg, fileTargetPath); err != nil {
			return err
		}
	}
	return nil
}

func (c ConfigGenerator) generateIgnBootstrapConfig(clusterDir string, ignTemplatesPath string) error {
	// retrieve ign templates
	ignTemplates, err := getIgnTemplates(ignTemplatesPath)
	if err != nil {
		return fmt.Errorf("failed to retrieve ign templates: %v", err)
	}

	// initialise bootstrap config
	bootstrapConfig, err := c.initBootstrapConfig()
	if err != nil {
		return fmt.Errorf("failed to initialise bootstrap ign config: %v", err)
	}

	// yaml -> ctCfg
	ctConfig, err := ignYAMLToCTConfig(*bootstrapConfig, *ignTemplates)
	if err != nil {
		return fmt.Errorf("failed to convert ign yaml templates to ct config: %v", err)
	}

	// ctCfg -> ignCfg
	ignCfg, rep := ctconfig.Convert(*ctConfig, "", nil)
	if len(rep.Entries) > 0 {
		return fmt.Errorf("failed to convert ct config to ignition config %s", rep)
	}

	// ignCfg -> File/json
	return ignCfgToFile(ignCfg, filepath.Join(clusterDir, config.IgnitionBootstrap))
}

func renderTemplateList(bootstrapConfig bootstrapConfig, templates []string) ([][]byte, error) {
	var data [][]byte
	for _, t := range templates {
		// yaml template -> populated yaml data
		rendered, err := renderTemplate(bootstrapConfig, t)
		if err != nil {
			return nil, err
		}
		data = append(data, rendered)
	}
	return data, nil
}

func renderTemplate(config interface{}, path string) ([]byte, error) {
	data, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("failed to render template %s: %v", path, err)
	}

	tmpl, err := template.New("").Parse(string(data))
	if err != nil {
		return nil, fmt.Errorf("parsing template %s: %v", path, err)
	}

	buf := new(bytes.Buffer)
	if err := tmpl.Execute(buf, config); err != nil {
		return nil, fmt.Errorf("executing template for file %s: %v", path, err)
	}
	return buf.Bytes(), nil
}

func ignYAMLToCTConfig(bootstrapConfig bootstrapConfig, ignTemplates ignTemplates) (*ctconfigtypes.Config, error) {
	var ctConfig ctconfigtypes.Config

	// files
	filesData, err := renderTemplateList(bootstrapConfig, ignTemplates.filesPaths)
	if err != nil {
		return nil, err
	}
	for _, data := range filesData {
		// populated yaml data -> ctCfg
		f := new(ctconfigtypes.File)
		if err := yaml.Unmarshal(data, f); err != nil {
			return nil, fmt.Errorf("failed to unmarshal file into struct: %v", err)
		}
		ctConfig.Storage.Files = append(ctConfig.Storage.Files, *f)
	}

	// units
	unitsData, err := renderTemplateList(bootstrapConfig, ignTemplates.unitsPaths)
	if err != nil {
		return nil, err
	}
	for _, data := range unitsData {
		// populated yaml data -> ctCfg
		u := new(ctconfigtypes.SystemdUnit)
		if err := yaml.Unmarshal(data, u); err != nil {
			return nil, fmt.Errorf("failed to unmarshal unit into struct: %v", err)
		}
		ctConfig.Systemd.Units = append(ctConfig.Systemd.Units, *u)
	}
	return &ctConfig, nil
}

func getIgnTemplates(ignTemplatesPath string) (*ignTemplates, error) {
	filesBaseDir := filepath.Join(ignTemplatesPath, filesTemplatesFolder)
	unitsBaseDir := filepath.Join(ignTemplatesPath, unitsTemplatesFolder)

	filesInfos, err := ioutil.ReadDir(filesBaseDir)
	if err != nil {
		return nil, fmt.Errorf("failed to read templates for path %s: %v", filesTemplatesFolder, err)
	}

	unitsInfos, err := ioutil.ReadDir(unitsBaseDir)
	if err != nil {
		return nil, fmt.Errorf("failed to read templates for path %s: %v", unitsTemplatesFolder, err)
	}

	var filesPaths []string
	for _, file := range filesInfos {
		filesPaths = append(filesPaths, filepath.Join(filesBaseDir, file.Name()))
	}
	var unitsPaths []string
	for _, file := range unitsInfos {
		unitsPaths = append(unitsPaths, filepath.Join(unitsBaseDir, file.Name()))
	}

	ignTemplates := &ignTemplates{
		filesPaths: filesPaths,
		unitsPaths: unitsPaths,
	}
	return ignTemplates, nil
}

func (c ConfigGenerator) initBootstrapConfig() (*bootstrapConfig, error) {
	clusterDNSIP, err := c.getClusterDNSIP()
	if err != nil {
		return nil, err
	}

	bootstrapConfig := &bootstrapConfig{
		AssetsS3Location:      c.getInitAssetsLocation(),
		AwscliImage:           "quay.io/coreos/awscli:025a357f05242fdad6a81e8a6b520098aa65a600",
		CloudProvider:         "aws",
		ClusterDNSIP:          clusterDNSIP,
		HyperkubeImage:        "quay.io/coreos/hyperkube:v1.9.1_coreos.0",
		KubecorerendererImage: "quay.io/coreos/kube-core-renderer-dev:4ed85ee12e167da71e7d5f06ffdb94d1ce21f540",
		BootkubeImage:         "quay.io/coreos/bootkube:v0.10.0",
	}
	return bootstrapConfig, nil
}

func parseIgnFile(filePath string) (*ignconfigtypes.Config, error) {
	if filePath == "" {
		ignition := &ignconfigtypes.Ignition{
			Version: ignVersion,
		}
		return &ignconfigtypes.Config{Ignition: *ignition}, nil
	}

	data, err := ioutil.ReadFile(filePath)
	if err != nil {
		return nil, err
	}

	cfg, rpt, _ := ignconfig.Parse(data)
	if len(rpt.Entries) > 0 {
		return nil, fmt.Errorf("failed to parse ignition file %s: %s", filePath, rpt.String())
	}

	return &cfg, nil
}

func (c ConfigGenerator) embedAppendBlock(ignCfg *ignconfigtypes.Config, role string) *ignconfigtypes.Config {
	appendBlock := ignconfigtypes.ConfigReference{
		c.getTNCURL(role),
		ignconfigtypes.Verification{Hash: nil},
	}
	ignCfg.Ignition.Config.Append = append(ignCfg.Ignition.Config.Append, appendBlock)
	return ignCfg
}

func getKubeconfigKubeletContent(clusterDir string) ([]byte, error) {
	kubeconfigKubeletPath := filepath.Join(clusterDir, kubeconfigKubeletPath)
	return ioutil.ReadFile(kubeconfigKubeletPath)
}

func (c ConfigGenerator) embedKubeconfigKubeletBlock(ignCfg *ignconfigtypes.Config, kubeconfiKubeletContent []byte) *ignconfigtypes.Config {
	kubeconfigKubelet := ignconfigtypes.File{
		Node: ignconfigtypes.Node{
			Filesystem: "root",
			Path:       "/etc/kubernetes/kubeconfig",
		},
		FileEmbedded1: ignconfigtypes.FileEmbedded1{
			Contents: ignconfigtypes.FileContents{
				Source: fmt.Sprintf("data:text/plain;charset=utf-8;base64,%s", base64.StdEncoding.EncodeToString(kubeconfiKubeletContent)),
			},
			Mode: 420,
		},
	}
	ignCfg.Storage.Files = append(ignCfg.Storage.Files, kubeconfigKubelet)
	return ignCfg
}

func (c ConfigGenerator) getTNCURL(role string) string {
	var url string
	if role == "master" || role == "worker" {
		url = fmt.Sprintf("http://%s-tnc.%s/config/%s", c.Name, c.BaseDomain, role)
	}
	return url
}

func ignCfgToFile(ignCfg ignconfigtypes.Config, filePath string) error {
	data, err := json.MarshalIndent(&ignCfg, "", "  ")
	if err != nil {
		return err
	}

	return writeFile(filePath, string(data))
}

func writeFile(path, content string) error {
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()

	w := bufio.NewWriter(f)
	if _, err := fmt.Fprintln(w, content); err != nil {
		return err
	}
	w.Flush()

	return nil
}
