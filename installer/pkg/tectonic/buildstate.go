package tectonic

import (
	"bufio"
	"errors"
	"log"
	"os"
	"path/filepath"
	"strings"
)

type BuildState struct {
	Root string
}

// this method is TEMPORARY
// until we wire in the cluster config object
func ClusterNameFromVarfile(varfile string) (string, error) {
	vf, err := os.Open(varfile)
	if err != nil {
		log.Print(err)
		return "", err
	}
	defer vf.Close()
	scanner := bufio.NewScanner(vf)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasPrefix(line, "tectonic_cluster_name") {
			value := strings.Split(line, "=")[1]
			value = strings.TrimSpace(value)
			value = strings.Trim(value, "\"")
			return value, nil
		}
	}
	return "", errors.New("not found")
}

func NewBuildLocation(path ...string) string {
	pwd, _ := os.Getwd()
	path = append([]string{pwd}, path...)
	buildPath := filepath.Join(path...)
	err := os.MkdirAll(buildPath, os.ModeDir|0755)
	if err != nil {
		log.Fatalf("Failed to create build folder at %s", buildPath)
	}
	return buildPath
}

// implement actual detection of templates
func FindTemplatesForType(buildType string) string {
	pwd, _ := os.Getwd()
	return filepath.Join(pwd, "platforms", buildType)
}

// implement actual detection of templates
func FindTemplatesForStep(step ...string) string {
	pwd, _ := os.Getwd()
	step = append([]string{pwd, "phases"}, step...)
	return filepath.Join(step...)
}
