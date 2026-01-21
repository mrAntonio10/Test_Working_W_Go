package main

import (
	"first/internal/bootstrap"
	"first/internal/middleware"
	"first/pkg/db"
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"github.com/labstack/echo/v4"
	echoMiddleware "github.com/labstack/echo/v4/middleware"
)

func main() {
	// 0. Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// 1. Connection to PostgreSQL
	// Build DSN from environment variables
	dsn := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=%s",
		getEnv("DB_USER", "postgres"),
		getEnv("DB_PASSWORD", ""),
		getEnv("DB_HOST", "localhost"),
		getEnv("DB_PORT", "5432"),
		getEnv("DB_NAME", "postgres"),
		getEnv("DB_SSLMODE", "disable"),
	)

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
	port := getEnv("SERVER_PORT", "1323")
	e.Logger.Fatal(e.Start(":" + port))
}

// getEnv gets an environment variable with a fallback default value
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
