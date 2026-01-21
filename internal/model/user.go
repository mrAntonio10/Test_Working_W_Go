package model

import (
	"github.com/google/uuid"
)

// User represents a user in the system.
type User struct {
	ID       uuid.UUID `json:"id" toon:"id" gorm:"primaryKey;type:uuid;default:gen_random_uuid()"`
	Name     string    `json:"name" toon:"name"`
	Email    string    `json:"email" toon:"email"`
	Password string    `json:"password" toon:"password"`
}
