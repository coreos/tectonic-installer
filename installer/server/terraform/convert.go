package terraform

import (
	"strings"
	"fmt"
	"strconv"
)


func MapVarsToTFVars(variables map[string]interface{}) (string, error) {
	tfVars := ""

	for key, value := range variables {
		var stringValue string

		switch value := value.(type) {
		case string:
			trimmedValue := strings.Trim(value, "\n")
			if !strings.Contains(trimmedValue, "\n") {
				stringValue = fmt.Sprintf("\"%s\"", trimmedValue)
			} else {
				stringValue = fmt.Sprintf("<<EOD\n%s\nEOD", trimmedValue)
			}
		case []string:
			qValue := make([]string, len(value))
			for i := 0; i < len(value); i++ {
				qValue[i] = fmt.Sprintf("\"%s\"", strings.Trim(value[i], "\n"))
			}
			stringValue = fmt.Sprintf("[%s]", strings.Join(qValue, ", "))
		case int:
			stringValue = strconv.Itoa(value)
		default:
			return "", fmt.Errorf("unsupported type %T (%s) for TFVars\n", value, key)
		}

		tfVars = fmt.Sprintf("%s%s = %s\n", tfVars, key, stringValue)
	}

	return tfVars, nil
}