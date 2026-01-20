package core

import (
	m "first/internal/model"
	"first/internal/repository"
)

type UserService interface {
	GetUsers() ([]m.User, error)
	CreateUser(user *m.User) error
}

type userService struct {
	repo repository.UserRepository
}

func NewUserService(repo repository.UserRepository) UserService {
	return &userService{repo: repo}
}

func (s *userService) GetUsers() ([]m.User, error) {
	return s.repo.GetAll()
}

func (s *userService) CreateUser(user *m.User) error {
	// Business logic could go here (e.g. validation)
	return s.repo.Create(user)
}
