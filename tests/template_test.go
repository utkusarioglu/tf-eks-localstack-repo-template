package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestTemplate(t *testing.T) {
	t.Parallel()
	repoPath := ".."
	terraformOptions := &terraform.Options{
		TerraformDir: repoPath,
	}

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		output := terraform.Output(t, terraformOptions, "greeting")
		assert.Equal(t, "Hello, terraform-aws-eks-repo-template!", output)
	})

	test_structure.RunTestStage(t, "teardown", func() {
		terraform.Destroy(t, &terraform.Options{
			TerraformDir: repoPath,
			Logger:       logger.Discard,
		})
	})
}
