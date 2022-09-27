package test

import (
	"fmt"
	"io/ioutil"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/logger"
)

func retrieveVarFiles(t *testing.T) []string {
	varsFolder := "vars"
	files, err := ioutil.ReadDir(fmt.Sprintf("../%s", varsFolder))
	if err != nil {
		logger.Log(t, err)
	}
	varFiles := []string{}
	for _, file := range files {
		filename := file.Name()
		isDisabled := strings.Contains(filename, ".disabled.")
		isTfVars := strings.HasSuffix(filename, ".tfvars")
		isTfVarsJson := strings.HasSuffix(filename, ".tfvars.json")
		isExample := strings.Contains(filename, ".example")
		if !isDisabled && (isTfVars || isTfVarsJson) && !isExample {
			varFiles = append(varFiles, fmt.Sprintf("%s/%s", varsFolder, filename))
		}
	}
	return varFiles
}

func createTimestamp() string {
	now := time.Now()
	timestamp := fmt.Sprintf(
		"%d-%02d-%02d-%02d-%02d-%02d",
		now.Year(),
		now.Month(),
		now.Day(),
		now.Hour(),
		now.Minute(),
		now.Second(),
	)
	return timestamp
}
