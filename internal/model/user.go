package model

// User represents a user in the system.
type User struct {
	ID    int    `json:"id" toon:"id"`
	Name  string `json:"name" toon:"name"`
	Email string `json:"email" toon:"email"`
}
