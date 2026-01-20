package main

import (
	"first/internal/controller"
	"first/internal/core"
	"first/internal/middleware"
	"first/internal/repository"
	"first/pkg/db"
	"log"

	"github.com/labstack/echo/v4"
	echoMiddleware "github.com/labstack/echo/v4/middleware"
)

func main() {
	// 1. Connection to PostgreSQL
	// Replace the DSN with your actual credentials
	dsn := "postgres://user:password@localhost:5432/dbname?sslmode=disable"
	database, err := db.NewPostgresDB(dsn)
	if err != nil {
		log.Fatalf("Could not connect to database: %v", err)
	}
	defer database.Close()

	// 2. Initialize Dependency Injection (Repo -> Service -> Controller)
	userRepo := repository.NewPostgresUserRepository(database)
	userService := core.NewUserService(userRepo)
	userController := controller.NewUserController(userService)

	// 3. Setup Echo Server
	e := echo.New()
	e.Use(echoMiddleware.Logger())
	e.Use(echoMiddleware.Recover())

	// 4. Configure TOON Middleware/Serializer
	// This replaces the default JSON serializer with our TOON serializer
	e.JSONSerializer = &middleware.ToonSerializer{}

	// 5. Register Routes
	userController.RegisterRoutes(e)

	e.GET("/", func(c echo.Context) error {
		return c.String(200, "Server is running with TOON support!")
	})

	// 6. Start Server
	e.Logger.Fatal(e.Start(":1323"))
}
