package main

import (
	"log"
	"os"

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
			w := workflow.NewInstallWorkflow(
				workflow.Metadata{
					"var_file":     *clusterConfigFlag,
					"cluster_name": clusterName,
				},
			)
			w.Execute()
		}
	case clusterDeleteCommand.FullCommand():
		{
			buildPath := *deleteClusterDir
			pathStat, err := os.Stat(buildPath)
			// TODO: add deeper checking of the path for having cluster state
			if os.IsNotExist(err) || !pathStat.IsDir() {
				log.Fatalf("Provided path %s is not valid cluster state location.")
			}
			w := workflow.NewDestroyWorkflow(
				workflow.Metadata{
					"build_path": buildPath,
				},
			)
			w.Execute()
		}
	}
}
