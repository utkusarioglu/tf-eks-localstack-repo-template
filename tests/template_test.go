package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestTemplate(t *testing.T) {
	t.Parallel()
	repoPath := ".."
	varFiles := retrieveVarFiles(t)
	timestamp := createTimestamp()

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: repoPath,
			VarFiles:     varFiles,
			EnvVars: map[string]string{
				"TF_LOG_PATH": fmt.Sprintf("logs/%s.terratest.log", timestamp),
				"TF_LOG":      "DEBUG",
			},
		})
		test_structure.SaveTerraformOptions(t, ".", terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, ".")
		output := terraform.Output(t, terraformOptions, "greeting")
		assert.Equal(t, "Hello, terraform-eks-repo-template!", output)
	})

	test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, ".")
		terraform.Destroy(t, terraformOptions)
	})
}
