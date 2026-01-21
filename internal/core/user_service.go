package core

import (
	m "first/internal/model"
	"first/pkg/utils"
)

type UserService interface {
	GetUsersPaginated(page, pageSize int) (*utils.PaginatedResponse, error)
	GetUserByEmail(email string) (*m.User, error)
	CreateUser(name, email, password string) error
}
