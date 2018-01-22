package workflow

import (
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/coreos/tectonic-installer/installer/pkg/tectonic"
)

func runTfCommand(buildPath string, args ...string) error {
	tfInit := exec.Command("terraform", args...) // TODO: get from cluster config
	tfInit.Dir = buildPath
	tfInit.Stdin = os.Stdin
	tfInit.Stdout = os.Stdout
	tfInit.Stderr = os.Stderr
	err := tfInit.Run()
	if err != nil {
		return err
	}
	return nil
}

func terraformApply(m *Metadata, stateFile string, templatesPath string) error {
	bp := (m.GetValue("build_path")).(string)
	log.Printf("Installation is running...")
	command := []string{
		"apply",
		"-state=" + stateFile,
		templatesPath,
	}
	err := runTfCommand(bp, command...)
	if err != nil {
		return err
	}
	return nil
}

type terraformCleanStep struct{}

func (s terraformCleanStep) Execute(m *Metadata) error {
	bp := (m.GetValue("build_path")).(string)
	err := os.RemoveAll(bp)
	if err != nil {
		return err
	}
	return nil
}

type terraformPrepareStep struct{}

func (s terraformPrepareStep) Execute(m *Metadata) error {
	clusterName := m.GetValue("cluster_name").(string)
	buildPath := tectonic.NewBuildLocation(clusterName)
	m.SetValue("build_path", buildPath)
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
	log.Printf("Initializing cluster %s...", m.GetValue("cluster_name").(string))
	bp := (m.GetValue("build_path")).(string)
	// TODO: get from cluster config
	templatesPath := tectonic.FindTemplatesForType("aws")
	err := runTfCommand(bp, "init", templatesPath)
	if err != nil {
		return err
	}
	return nil
}
