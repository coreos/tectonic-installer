package client

import (
	"github.com/coreos-inc/operator-client/pkg/types"

	"github.com/golang/glog"

	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/pkg/api"
	"k8s.io/client-go/pkg/api/errors"
	"k8s.io/client-go/pkg/api/unversioned"
)

// Migration describes the basic interface for a Migraton implementation.
type Migration interface {
	Run(client kubernetes.Interface, namespace, name string) error
}

// FunctionMigration is a migration defined as a pure-go function.
type FunctionMigration func(client kubernetes.Interface, namespace, name string) error

// Run will invoke the migration.
func (fm FunctionMigration) Run(client kubernetes.Interface, namespace, name string) error {
	return fm(client, namespace, name)
}

// MigrationList holds the list of before / after migrations to be ran.
type MigrationList struct {
	// The version these migrations are running for.
	Version string
	// Migrations to be run before an update.
	Before []Migration
	// Migrations to be run after an update.
	After []Migration
}

// RunBeforeMigrations will run all before migrations, updating the corresponding
// MigrationStatus object as it runs through the list.
func (ml *MigrationList) RunBeforeMigrations(client Interface, namespace, name string) error {
	return runMigrations(client, ml.Before, types.MigrationStageBefore, ml.Version, namespace, name)
}

// RunAfterMigrations will run all after migrations, updating the corresponding
// MigrationStatus object as it runs through the list.
func (ml *MigrationList) RunAfterMigrations(client Interface, namespace, name string) error {
	return runMigrations(client, ml.After, types.MigrationStageAfter, ml.Version, namespace, name)
}

func runMigrations(client Interface, migs []Migration, stage types.MigrationStage, version, namespace, name string) error {
	ms, err := client.GetMigrationStatus(name)
	if err != nil && !errors.IsNotFound(err) {
		return err
	}
	i := 0
	if ms != nil {
		switch stage {
		case types.MigrationStageBefore:
			if v, ok := ms.Versions[version]; ok && v.LastBeforeMigrationRan != nil {
				i = *v.LastBeforeMigrationRan + 1
			}
		case types.MigrationStageAfter:
			if v, ok := ms.Versions[version]; ok && v.LastAfterMigrationRan != nil {
				i = *v.LastAfterMigrationRan + 1
			}
		}
	} else if len(migs) > 0 {
		ms, err = createMigrationStatus(client, name)
		if err != nil {
			return err
		}
	}
	for ; i < len(migs); i++ {
		glog.Infof("Running %s migration %d for component %s", stage, i, name)

		if err = migs[i].Run(client.KubernetesInterface(), namespace, name); err != nil {
			return err
		}
		ms, err = updateMigrationStatus(client, ms, version, i, stage)
		if err != nil {
			return err
		}
	}
	return nil
}

func createMigrationStatus(client Interface, name string) (*types.MigrationStatus, error) {
	return client.CreateMigrationStatus(&types.MigrationStatus{
		TypeMeta: unversioned.TypeMeta{
			Kind:       types.MigrationStatusKind,
			APIVersion: types.MigrationAPIGroup + "/" + types.MigrationTPRVersion,
		},
		ObjectMeta: api.ObjectMeta{
			Name:      name,
			Namespace: types.TectonicNamespace,
		},
	})
}

func updateMigrationStatus(client Interface, ms *types.MigrationStatus, v string, n int, stage types.MigrationStage) (*types.MigrationStatus, error) {
	if _, ok := ms.Versions[v]; !ok {
		if ms.Versions == nil {
			ms.Versions = make(types.MigrationVersions)
		}
		ms.Versions[v] = new(types.MigrationVersion)
	}
	m := n
	switch stage {
	case types.MigrationStageBefore:
		ms.Versions[v].LastBeforeMigrationRan = &m
	case types.MigrationStageAfter:
		ms.Versions[v].LastAfterMigrationRan = &m
	}
	return client.UpdateMigrationStatus(ms)
}
