package bootstrap

import (
	"first/internal/controller"
	"first/internal/core"
	"first/internal/model"
	"first/internal/repository"
	"log"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

// InitApp initializes the application components (Use Cases, Repos, Controllers)
// and registers routes.
func InitApp(e *echo.Echo, db *gorm.DB) {
	// --- Migrations ---
	// In production, this might be handled by a separate migration tool.
	migrate(db)

	// --- Dependency Injection ---
	// Here we wire up our Clean Architecture layers.
	// As the app grows, we can split this into private functions like `initUsers(e, db)`, `initOrders(e, db)`, etc.
	
	initUserModule(e, db)

	// Add new modules here...
	// initProductModule(e, db)
}

func migrate(db *gorm.DB) {
	if err := db.AutoMigrate(&model.User{}); err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}
}

// initUserModule bundles all User-related wiring
func initUserModule(e *echo.Echo, db *gorm.DB) {
	repo := repository.NewPostgresUserRepository(db)
	service := core.NewUserService(repo)
	ctrl := controller.NewUserController(service)

	ctrl.RegisterRoutes(e)
}
