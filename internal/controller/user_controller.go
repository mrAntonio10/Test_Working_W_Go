package controller

import (
	"first/internal/core"
	"first/internal/model"
	"net/http"

	"github.com/labstack/echo/v4"
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
}

func (ctrl *UserController) GetUsers(c echo.Context) error {
	users, err := ctrl.service.GetUsers()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}
	return c.JSON(http.StatusOK, users)
}

func (ctrl *UserController) CreateUser(c echo.Context) error {
	var user model.User
	if err := c.Bind(&user); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request"})
	}

	if err := ctrl.service.CreateUser(&user); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, user)
}
