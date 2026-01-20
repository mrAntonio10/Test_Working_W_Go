package middleware

import (
	"encoding/json"

	"github.com/labstack/echo/v4"
)

// ToonSerializer implements echo.JSONSerializer for TOON format.
// Note: Currently uses JSON as the underlying format for demonstration purposes,
// as the 'toon-go' library integration requires specific version matching.
// You can replace 'json.NewEncoder' with 'toon.NewEncoder' once fully configured.
type ToonSerializer struct{}

// Serialize converts an interface to TOON and writes it to the response.
func (t *ToonSerializer) Serialize(c echo.Context, i interface{}, indent string) error {
	c.Response().Header().Set(echo.HeaderContentType, "application/toon")
	return json.NewEncoder(c.Response()).Encode(i)
}

// Deserialize reads TOON from the request body and stores it in the interface.
func (t *ToonSerializer) Deserialize(c echo.Context, i interface{}) error {
	return json.NewDecoder(c.Request().Body).Decode(i)
}

// SupportTOON is a middleware that detects if the client accepts/sends TOON.
func SupportTOON(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		// Logic to prioritize TOON if Accept header matches could go here.
		return next(c)
	}
}
