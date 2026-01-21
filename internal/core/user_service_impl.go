package core

import (
	"errors"
	m "first/internal/model"
	"first/internal/repository"
	"first/pkg/utils"

	"golang.org/x/crypto/bcrypt"
)

type userServiceImpl struct {
	repo repository.UserRepository
}

func NewUserService(repo repository.UserRepository) UserService {
	return &userServiceImpl{repo: repo}
}

func (s *userServiceImpl) GetUsersPaginated(page, pageSize int) (*utils.PaginatedResponse, error) {
	users, total, err := s.repo.GetAllPaginated(page, pageSize)
	if err != nil {
		return nil, err
	}

	totalPages := int((total + int64(pageSize) - 1) / int64(pageSize))

	return &utils.PaginatedResponse{
		Data:       users,
		Total:      total,
		Page:       page,
		PageSize:   pageSize,
		TotalPages: totalPages,
	}, nil
}

func (s *userServiceImpl) CreateUser(name, email, password string) error {
	// Business logic: Validation
	if name == "" || email == "" || password == "" {
		return errors.New("name, email, and password are required")
	}

	// Business logic: Hashing
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	return s.repo.Create(name, email, string(hashedPassword))
}

func (s *userServiceImpl) GetUserByEmail(email string) (*m.User, error) {
	return s.repo.GetByEmail(email)
}
