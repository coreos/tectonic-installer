package main

import (
	"log"

	"github.com/coreos/tectonic-installer/installer/pkg/tectonic"
	"github.com/coreos/tectonic-installer/installer/pkg/workflow"
	"gopkg.in/alecthomas/kingpin.v2"
)

var (
	dryRunFlag            = kingpin.Flag("dry-run", "Just pretend, but don't do anything.").Bool()
	clusterInstallCommand = kingpin.Command("install", "Create a new Tectonic cluster.")
	clusterDeleteCommand  = kingpin.Command("delete", "Delete an existing Tectonic cluster.")
	deleteClusterDir      = clusterDeleteCommand.Arg("dir", "The name of the cluster to delete").String()
	clusterConfigFlag     = clusterInstallCommand.Flag("config", "Cluster specification file").Required().ExistingFile()
)

func main() {
	switch kingpin.Parse() {
	case clusterInstallCommand.FullCommand():
		{
			clusterName, err := tectonic.ClusterNameFromVarfile(*clusterConfigFlag)
			if err != nil {
				log.Fatalf("%s is not a valid config file", *clusterConfigFlag)
			}
			w := workflow.NewNcgBootsrapWorkflow(
				workflow.Metadata{
					"var_file":     *clusterConfigFlag,
					"cluster_name": clusterName,
				},
			)
			if err := w.Execute(); err != nil {
				log.Fatal(err)
			}
		}
	case clusterDeleteCommand.FullCommand():
		{
			// TODO up next
		}
	}
}
