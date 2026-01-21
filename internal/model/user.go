package model

// User represents a user in the system.
type User struct {
	ID    int    `json:"id" toon:"id" gorm:"primaryKey"`
	Name     string `json:"name" toon:"name"`
	Email    string `json:"email" toon:"email"`
	Password string `json:"password" toon:"password"`
}
