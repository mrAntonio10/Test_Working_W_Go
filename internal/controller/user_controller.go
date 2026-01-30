package controller

import (
	"first/internal/core"
	"first/pkg/utils"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
	"golang.org/x/crypto/bcrypt"
)

type UserController struct {
	service core.UserService
}

func NewUserController(service core.UserService) *UserController {
	return &UserController{service: service}
}

func (ctrl *UserController) RegisterRoutes(e *echo.Echo) {
	e.GET("/users", ctrl.GetUsers)
	e.POST("/users", ctrl.CreateUser)
	e.POST("/login", ctrl.Login)
}

func (ctrl *UserController) GetUsers(c echo.Context) error {
	page, _ := strconv.Atoi(c.QueryParam("page"))
	if page < 1 {
		page = 1
	}

	pageSize, _ := strconv.Atoi(c.QueryParam("page_size"))
	if pageSize < 1 {
		pageSize = 10
	}

	response, err := ctrl.service.GetUsersPaginated(page, pageSize)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}
	return c.JSON(http.StatusOK, response)
}

func (ctrl *UserController) CreateUser(c echo.Context) error {
	var payload CreateUserPayload
	if err := c.Bind(&payload); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request"})
	}

	if err := ctrl.service.CreateUser(payload.Name, payload.Email, payload.Password); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, map[string]string{"message": "User created successfully"})
}

type CreateUserPayload struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginResponse struct {
	Message string   `json:"message"`
	Token   string   `json:"token"`
	User    UserData `json:"user"`
}

type UserData struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

func (ctrl *UserController) Login(c echo.Context) error {
	var req LoginRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request"})
	}

	user, err := ctrl.service.GetUserByEmail(req.Email)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Invalid credentials"})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Invalid credentials"})
	}

	// Generate JWT token
	token, err := utils.GenerateJWT(user.ID, user.Email)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to generate token"})
	}

	// Prepare response
	response := LoginResponse{
		Message: "Login successful",
		Token:   token,
		User: UserData{
			ID:    user.ID.String(),
			Name:  user.Name,
			Email: user.Email,
		},
	}

	return c.JSON(http.StatusOK, response)
}
