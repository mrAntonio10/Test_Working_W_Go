package utils

import "fmt"

func ValidateNotEmpty(value, fieldName string) error {
	if value == "" {
		return fmt.Errorf("The value [%s] could not be empty", fieldName)
	}
	return nil
}
