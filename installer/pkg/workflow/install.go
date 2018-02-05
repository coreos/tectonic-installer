package workflow

import (
	"io"
	"log"
	"os"
	"path/filepath"
	"time"

	"github.com/coreos/tectonic-installer/installer/pkg/tectonic"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

const configFileName string = "config.yaml"

// NewInstallWorkflow creates new instances of the 'install' workflow,
// responsible for running the actions necessary to install a new cluster.
func NewInstallWorkflow(configFile string) Workflow {
	clusterName, err := tectonic.ClusterNameFromConfig(configFile) // TODO @spangenberg: re-implement with config object
	if err != nil {
		log.Fatalf("%s is not a valid config file", configFile)
	}

	// TODO: Discrimitate by config provider. if platform is aws:
	return simpleWorkflow{
		metadata: metadata{
			clusterName: clusterName,
			configFile:  configFile,
		},
		steps: []Step{
			terraformPrepareStep,
			tlsStep,
			assetsStep,
			ignitionStep,
			bootstrapStep,
			joiningStep,
		},
	}

	//return SimpleWorkflow{
	//	metadata: metadata{
	//		"var_file":     configFile,
	//		"cluster_name": clusterName,
	//	},
	//	steps: []Step{
	//		terraformPrepareStep,
	//		terraformInitStep,
	//		terraformApplyStep,
	//	},
	//}
}

func terraformPrepareStep(m *metadata) error {
	if m.statePath == "" {
		m.statePath = tectonic.NewBuildLocation(m.clusterName)
	}
	varfile := filepath.Join(m.statePath, configFileName)
	if _, err := os.Stat(varfile); os.IsNotExist(err) {
		from, err := os.Open(m.configFile)
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

//func terraformInitStep(m *metadata) error {
//	log.Printf("Initializing cluster ...")
//	err := tfInit(m.statePath, tectonic.FindTemplatesForType("aws"))
//	if err != nil {
//		return err
//	}
//	return nil
//}
//
//func terraformApplyStep(m *metadata) error {
//	log.Printf("Installation is running...")
//	err := tfApply(m.statePath, "state", tectonic.FindTemplatesForType("aws"))
//	if err != nil {
//		return err
//	}
//	return nil
//}

func tlsStep(m *metadata) error {
	log.Printf("Installation is running...")
	err := runStep(m.statePath, "tls")
	if err != nil {
		return err
	}
	return nil
}

func assetsStep(m *metadata) error {
	log.Printf("Installation is running...")
	err := runStep(m.statePath, "assets")
	if err != nil {
		return err
	}
	return nil
}

func ignitionStep(m *metadata) error {
	log.Printf("Installation is running...")
	err := runStep(m.statePath, "ignition")
	if err != nil {
		return err
	}
	return nil
}

func bootstrapStep(m *metadata) error {
	log.Printf("Installation is running...")
	err := runStep(m.statePath, "bootstrap")
	if err != nil {
		return err
	}
	err = waitForNcg(m)
	if err != nil {
		return err
	}
	err = destroyCname(m)
	if err != nil {
		return err
	}
	return nil
}

func joiningStep(m *metadata) error {
	// TODO: import will fail after a first run, error is ignored for now
	importAutoScalingGroup(m)
	log.Printf("Installation is running...")
	err := runStep(m.statePath, "joining")
	if err != nil {
		return err
	}
	return nil
}

// Helpers
func waitForNcg(m *metadata) error {
	kubeconfigPath := m.statePath + "/generated/auth/kubeconfig"
	config, err := clientcmd.BuildConfigFromFlags("", kubeconfigPath)
	if err != nil {
		return err
	}

	client, err := kubernetes.NewForConfig(config)
	if err != nil {
		return err
	}
	// TODO: add time out
	for {
		ds, err := client.DaemonSets("kube-system").Get("ncg")
		if err != nil {
			log.Printf("Waiting for NCG to be running, this might take a while... %v", err)
		}
		log.Printf("Installation is running...")
		if ds.Status.NumberReady >= 1 {
			break
		}
		time.Sleep(time.Second * 5)
	}
	return nil
}

func destroyCname(m *metadata) error {
	bp := m.statePath
	log.Printf("Installation is running...")
	err := runTfCommand(bp, "destroy", "-force", "-state=bootstrap.tfstate", "-target=aws_route53_record.tectonic_ncg", tectonic.FindTemplatesForStep("bootstrap"))
	if err != nil {
		return err
	}
	return nil

}

func importAutoScalingGroup(m *metadata) error {
	bp := m.statePath
	log.Printf("Installation is running...")
	err := runTfCommand(bp, "import", "-state=joining.tfstate", "-config="+tectonic.FindTemplatesForStep("joining"), "aws_autoscaling_group.masters", m.clusterName+"-masters")
	if err != nil {
		return err
	}
	return nil

}

func runStep(buildPath string, step string) error {
	codePath := tectonic.FindTemplatesForStep(step)
	err := tfInit(buildPath, codePath)
	if err != nil {
		return err
	}

	err = tfApply(buildPath, step, codePath)
	if err != nil {
		return err
	}
	return nil
}
