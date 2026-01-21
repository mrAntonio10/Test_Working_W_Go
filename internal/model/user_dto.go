package model

type UserResponseForPagination struct {
	Name  string `json:"name" toon:"name"`
	Email string `json:"email" toon:"email"`
}
