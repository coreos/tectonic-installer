package workflow

import (
	"os"
	"testing"
)

func TestTerraformPrepareStep(t *testing.T) {
	m := Metadata{
		"var_file":     "./fixtures/test.tfvars",
		"cluster_name": "test-cluster",
	}

	tf := terraformPrepareStep{}
	tf.Execute(&m)
	expectedFolder := "test-cluster"
	expectedFile := "test-cluster/terraform.tfvars"

	if _, err := os.Stat(expectedFolder); os.IsNotExist(err) {
		t.Errorf("Build folder test-cluster not created: %s", err)
	}

	_, err2 := os.Stat(expectedFile)
	if err2 != nil {
		t.Errorf("Var file not created")
	}

}

func TestTerraformCleanStep(t *testing.T) {
	m := Metadata{
		"var_file":     "./fixtures/test.tfvars",
		"cluster_name": "test-cluster",
	}
	tf := terraformPrepareStep{}
	tf.Execute(&m)

	tf2 := terraformCleanStep{}
	tf2.Execute(&m)
	expectedFolder := "test-cluster"

	_, err := os.Stat(expectedFolder)
	if err != nil {
		return
	}
	t.Errorf("Folder was not cleaned")
}
