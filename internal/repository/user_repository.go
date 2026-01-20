package repository

import (
	m "first/internal/model"

	"gorm.io/gorm"
)

type UserRepository interface {
	GetAll() ([]m.User, error)
	Create(user *m.User) error
}

type postgresUserRepository struct {
	db *gorm.DB
}

func NewPostgresUserRepository(db *gorm.DB) UserRepository {
	return &postgresUserRepository{db: db}
}

func (r *postgresUserRepository) GetAll() ([]m.User, error) {
	var users []m.User
	result := r.db.Find(&users)
	return users, result.Error
}

func (r *postgresUserRepository) Create(user *m.User) error {
	return r.db.Create(user).Error
}
