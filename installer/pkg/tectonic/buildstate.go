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

func NewBuildLocation(clusterName string) string {
	pwd, _ := os.Getwd()
	buildPath := filepath.Join(pwd, clusterName)
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
