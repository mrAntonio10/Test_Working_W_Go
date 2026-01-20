package main

import (
	"first/internal/bootstrap"
	"first/internal/middleware"
	"first/pkg/db"
	"log"

	"github.com/labstack/echo/v4"
	echoMiddleware "github.com/labstack/echo/v4/middleware"
)

func main() {
	// 1. Connection to PostgreSQL
	// 1. Connection to PostgreSQL
	// Replace the DSN with your actual credentials
	dsn := "postgres://marcoro:4708@localhost:5432/postgres?sslmode=disable"
	database, err := db.NewPostgresDB(dsn)
	if err != nil {
		log.Fatalf("Could not connect to database: %v", err)
	}
	// defer database.Close() // GORM manages connection pooling

	// 2. Setup Echo Server
	e := echo.New()
	e.Use(echoMiddleware.Logger())
	e.Use(echoMiddleware.Recover())

	// 3. Configure TOON Middleware/Serializer
	e.JSONSerializer = &middleware.ToonSerializer{}

	// 4. Initialize Application Modules (Bootstrap)
	// This keeps main() clean and scalable.
	bootstrap.InitApp(e, database)

	e.GET("/", func(c echo.Context) error {
		return c.String(200, "Server is running with TOON support!")
	})

	// 5. Start Server
	e.Logger.Fatal(e.Start(":1323"))
}
