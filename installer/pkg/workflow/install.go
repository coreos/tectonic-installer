package workflow

import (
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/coreos/tectonic-installer/installer/pkg/tectonic"
)

func NewInstallWorkflow(userConfig Metadata) Workflow {
	return WorkflowType{
		metadata: userConfig,
		steps: []Step{
			terraformPrepareStep{},
			terraformInitStep{},
			terraformApplyStep{},
		},
	}
}

type terraformPrepareStep struct{}

func (s terraformPrepareStep) Execute(m *Metadata) error {
	var buildPath string
	buildPath = (m.GetValue("build_path")).(string)
	if buildPath == "" {
		clusterName := m.GetValue("cluster_name").(string)
		buildPath = tectonic.NewBuildLocation(clusterName)
		m.SetValue("build_path", buildPath)
	}
	varfile := filepath.Join(buildPath, "terraform.tfvars")
	if _, err := os.Stat(varfile); os.IsNotExist(err) {
		from, err := os.Open(m.GetValue("var_file").(string))
		if err != nil {
			return err
		}
		defer from.Close()
		to, err := os.OpenFile(varfile, os.O_RDWR|os.O_CREATE, 0666)
		if err != nil {
			return err
		}
		defer to.Close()
		_, err = io.Copy(to, from)
		if err != nil {
			return err
		}
	}
	return nil
}

type terraformInitStep struct{}

func (s terraformInitStep) Execute(m *Metadata) error {
	log.Printf("Initializing cluster ...")
	bp := (m.GetValue("build_path")).(string)
	tfInit := exec.Command("terraform", "init", tectonic.FindTemplatesForType("aws")) // TODO: get from cluster config
	tfInit.Dir = bp
	tfInit.Stdin = os.Stdin
	tfInit.Stdout = os.Stdout
	tfInit.Stderr = os.Stderr
	err := tfInit.Run()
	if err != nil {
		return err
	}
	return nil
}

type terraformApplyStep struct{}

func (s terraformApplyStep) Execute(m *Metadata) error {
	bp := (m.GetValue("build_path")).(string)
	log.Printf("Installation is running...")
	tfInit := exec.Command("terraform", "apply", tectonic.FindTemplatesForType("aws")) // TODO: get from cluster config
	tfInit.Dir = bp
	tfInit.Stdin = os.Stdin
	tfInit.Stdout = os.Stdout
	tfInit.Stderr = os.Stderr
	err := tfInit.Run()
	if err != nil {
		return err
	}
	return nil
}
