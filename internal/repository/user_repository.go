package repository

import (
	m "first/internal/model"

	"gorm.io/gorm"
)

type UserRepository interface {
	GetAllPaginated(page, pageSize int) ([]m.UserResponseForPagination, int64, error)
	GetByEmail(email string) (*m.User, error)
	Create(name, email, password string) error
}

type postgresUserRepository struct {
	db *gorm.DB
}

func NewPostgresUserRepository(db *gorm.DB) UserRepository {
	return &postgresUserRepository{db: db}
}

func (r *postgresUserRepository) GetAllPaginated(page, pageSize int) ([]m.UserResponseForPagination, int64, error) {
	var users []m.UserResponseForPagination
	var total int64

	// Get total count
	if err := r.db.Model(&m.User{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Calculate offset
	offset := (page - 1) * pageSize

	// Get paginated data
	result := r.db.Model(&m.User{}).Select("name", "email").Offset(offset).Limit(pageSize).Scan(&users)
	return users, total, result.Error
}

func (r *postgresUserRepository) Create(name, email, password string) error {
	user := m.User{
		Name:     name,
		Email:    email,
		Password: password,
	}
	return r.db.Create(&user).Error
}

func (r *postgresUserRepository) GetByEmail(email string) (*m.User, error) {
	var user m.User
	result := r.db.Where("email = ?", email).First(&user)
	return &user, result.Error
}
