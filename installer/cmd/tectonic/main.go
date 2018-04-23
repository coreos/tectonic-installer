package main

import (
	"os"

	log "github.com/Sirupsen/logrus"
	"gopkg.in/alecthomas/kingpin.v2"

	"github.com/coreos/tectonic-installer/installer/pkg/workflow"
)

var (
	clusterInitCommand           = kingpin.Command("init", "Initialize a new Tectonic cluster")
	clusterInitConfigFlag        = clusterInitCommand.Flag("config", "Cluster specification file").Required().ExistingFile()
	clusterInitWorkspaceNameFlag = clusterInitCommand.Flag("workspace", "Workspace folder name").Required().String()

	clusterInstallCommand          = kingpin.Command("install", "Create a new Tectonic cluster")
	clusterInstallAssetsCommand    = clusterInstallCommand.Command("assets", "Generate Tectonic assets.")
	clusterInstallBootstrapCommand = clusterInstallCommand.Command("bootstrap", "Create a single bootstrap node Tectonic cluster.")
	clusterInstallFullCommand      = clusterInstallCommand.Command("full", "Create a new Tectonic cluster").Default()
	clusterInstallJoinCommand      = clusterInstallCommand.Command("join", "Create master and worker nodes to join an exisiting Tectonic cluster.")
	clusterInstallWorkspaceFlag    = clusterInstallCommand.Flag("workspace", "Workspace directory").Default(".").ExistingDir()

	clusterDestroyCommand       = kingpin.Command("destroy", "Destroy an existing Tectonic cluster")
	clusterDestroyWorkspaceFlag = clusterDestroyCommand.Flag("workspace", "Workspace directory").Default(".").ExistingDir()

	convertCommand    = kingpin.Command("convert", "Convert a tfvars.json to a Tectonic config.yaml")
	convertConfigFlag = convertCommand.Flag("config", "tfvars.json file").Required().ExistingFile()

	logLevel = kingpin.Flag("log-level", "log level (e.g. \"debug\")").Default("info").Enum("debug", "info", "warn", "error", "fatal", "panic")
)

func main() {
	var c *workflow.Cluster
	var err error

	newCluster := func(clusterInstallDirFlag string) *workflow.Cluster {
		l, err := log.ParseLevel(*logLevel)
		if err != nil {
			// By definition we should never enter this condition since kingpin should be guarding against incorrect values.
			log.Fatalf("invalid log-level: %v", err)
		}
		log.SetLevel(l)

		c, err = workflow.NewCluster(clusterInstallDirFlag)
		if err != nil {
			log.Fatal(err)
			os.Exit(1)
		}
		return c
	}

	switch kingpin.Parse() {
	case clusterInitCommand.FullCommand():
		err = workflow.InitWorkspace(*clusterInitConfigFlag, *clusterInitWorkspaceNameFlag)
	case clusterInstallFullCommand.FullCommand():
		c = newCluster(*clusterInstallWorkspaceFlag)
		err = c.Install()
	case clusterInstallAssetsCommand.FullCommand():
		c = newCluster(*clusterInstallWorkspaceFlag)
		err = c.Assets()
	case clusterInstallBootstrapCommand.FullCommand():
		c = newCluster(*clusterInstallWorkspaceFlag)
		err = c.Bootstrap()
	case clusterInstallJoinCommand.FullCommand():
		c = newCluster(*clusterInstallWorkspaceFlag)
		err = c.Scale()
	case clusterDestroyCommand.FullCommand():
		c = newCluster(*clusterInstallWorkspaceFlag)
		err = c.Destroy()
	case convertCommand.FullCommand():
		err = workflow.TF2YAML(*convertConfigFlag)
	}

	if err != nil {
		log.Fatal(err)
		os.Exit(1)
	}
}
