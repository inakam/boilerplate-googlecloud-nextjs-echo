package main

import (
	"database/sql"
	"net/http"
	"os"

	_ "modernc.org/sqlite"

	"github.com/labstack/echo/v4"
)

func main() {
	mountPath := os.Getenv("MOUNT_PATH")
	db, err := sql.Open("sqlite", "file:"+mountPath+"/sqlite.db")
	if err != nil {
		panic(err)
	}

	ddl := `
	CREATE TABLE IF NOT EXISTS users (
		id   TEXT PRIMARY KEY,
		name TEXT NOT NULL,
		created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
	)
	`

	if _, err := db.Exec(ddl); err != nil {
		panic(err)
	}

	// Echo instance
	e := echo.New()
	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello, World!")
	})
	e.Logger.Fatal(e.Start(":80"))
}
