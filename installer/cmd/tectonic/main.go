package main

import (
	"log"

	"github.com/coreos/tectonic-installer/installer/pkg/workflow"
	"gopkg.in/alecthomas/kingpin.v2"
)

var (
	dryRunFlag            = kingpin.Flag("dry-run", "Just pretend, but don't do anything").Bool()
	clusterInstallCommand = kingpin.Command("install", "Create a new Tectonic cluster")
	clusterDeleteCommand  = kingpin.Command("delete", "Delete an existing Tectonic cluster")
	deleteClusterDir      = clusterDeleteCommand.Arg("dir", "The name of the cluster to delete").String()
	clusterConfigFlag     = clusterInstallCommand.Flag("config", "Cluster specification file").Required().ExistingFile()
)

func main() {
	switch kingpin.Parse() {
	case clusterInstallCommand.FullCommand():
		{
			w := workflow.NewInstallWorkflow(*clusterConfigFlag)
			if err := w.Execute(); err != nil {
				log.Fatal(err) // TODO: actually do proper error handling
			}
		}
	case clusterDeleteCommand.FullCommand():
		{
			w := workflow.NewDestroyWorkflow(*deleteClusterDir)
			if err := w.Execute(); err != nil {
				log.Fatal(err) // TODO: actually do proper error handling
			}
		}
	}
}
