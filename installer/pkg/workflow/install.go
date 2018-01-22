package workflow

import (
	"log"
	"time"

	"github.com/coreos/tectonic-installer/installer/pkg/tectonic"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

// Classic Bootstrap
func NewInstallWorkflow(userConfig Metadata) Workflow {
	return WorkflowType{
		metadata: userConfig,
		steps: []Step{
			terraformPrepareStep{},
			terraformInitStep{},
			bootstapNodeStep{},
		},
	}
}

// NCG Bootstrap
func NewNcgBootsrapWorkflow(userConfig Metadata) Workflow {
	return WorkflowType{
		metadata: userConfig,
		steps: []Step{
			terraformPrepareStep{},
			terraformInitStep{},
			bootstapNodeStep{},
			waitForNcgStep{},
			destroyCnameStep{},
			importGroupsStep{},
			joinningNodesStep{},
		},
	}
}

type waitForNcgStep struct{}

func (s waitForNcgStep) Execute(m *Metadata) error {
	bp := (m.GetValue("build_path")).(string)
	log.Printf("Installation is running...")
	kubeconfigPath := bp + "/generated/auth/kubeconfig"
	config, err := clientcmd.BuildConfigFromFlags("", kubeconfigPath)
	if err != nil {
		return err
	}

	client, err := kubernetes.NewForConfig(config)
	if err != nil {
		return err
	}

	for {
		ds, err := client.DaemonSets("tectonic-system").Get("ncg")
		if err != nil {
			log.Printf("Installation is running... %v", err)
		}
		log.Printf("Installation is running... %+v", ds.Status)
		if ds.Status.NumberReady >= 1 {
			break
		}
		time.Sleep(time.Second * 5)
	}
	return nil
}

type destroyCnameStep struct{}

func (s destroyCnameStep) Execute(m *Metadata) error {
	bp := (m.GetValue("build_path")).(string)
	log.Printf("Installation is running...")
	args := []string{
		"destroy",
		"-force",
		"-state=bootstrap_node.tfstate",
		"-target=aws_route53_record.tectonic_ncg",
		tectonic.FindTemplatesForType("aws"),
	}
	err := runTfCommand(bp, args...)
	if err != nil {
		return err
	}
	return nil
}

type importGroupsStep struct{}

func (s importGroupsStep) Execute(m *Metadata) error {
	bp := (m.GetValue("build_path")).(string)
	templatesPath := tectonic.FindTemplatesForStep("ncg-joinning-nodes", "aws")
	cluster_name := m.GetValue("cluster_name").(string)
	log.Printf("Installation is running...")
	args := []string{
		"import",
		"-state=joinning_nodes.tfstate",
		"-config=" + templatesPath,
		"aws_autoscaling_group.masters",
		cluster_name + "-masters",
	}

	// TODO: ensure idempotency, this complains on second run
	err := runTfCommand(bp, args...)
	if err != nil {
		return err
	}
	return nil
}

type joinningNodesStep struct{}

func (s joinningNodesStep) Execute(m *Metadata) error {
	templatesPath := tectonic.FindTemplatesForStep("ncg-joinning-nodes", "aws")
	terraformApply(m, "joinning_nodes.tfstate", templatesPath)
	return nil
}

type bootstapNodeStep struct{}

func (s bootstapNodeStep) Execute(m *Metadata) error {
	templatesPath := tectonic.FindTemplatesForType("aws")
	terraformApply(m, "bootstrap_node.tfstate", templatesPath)
	return nil
}
