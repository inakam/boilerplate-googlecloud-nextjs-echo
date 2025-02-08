package main

import (
	"database/sql"
	"net/http"
	"os"
	"time"

	"github.com/google/uuid"
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
	);

	CREATE TABLE IF NOT EXISTS access_logs (
		id   TEXT PRIMARY KEY,
		accessed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
	);
	`

	if _, err := db.Exec(ddl); err != nil {
		panic(err)
	}

	// Echo instance
	e := echo.New()

	e.GET("/", func(c echo.Context) error {
		// Generate UUID for this access
		accessID := uuid.New().String()

		// Log the access
		_, err := db.Exec("INSERT INTO access_logs (id, accessed_at) VALUES (?, ?)",
			accessID, time.Now())
		if err != nil {
			return err
		}

		return c.String(http.StatusOK, "Hello, World! Your access ID is "+accessID)
	})

	e.GET("/list", func(c echo.Context) error {
		rows, err := db.Query("SELECT id, accessed_at FROM access_logs ORDER BY accessed_at DESC")
		if err != nil {
			return err
		}
		defer rows.Close()

		var accessLogs []struct {
			ID         string    `json:"id"`
			AccessedAt time.Time `json:"accessed_at"`
		}

		for rows.Next() {
			var log struct {
				ID         string    `json:"id"`
				AccessedAt time.Time `json:"accessed_at"`
			}
			if err := rows.Scan(&log.ID, &log.AccessedAt); err != nil {
				return err
			}
			accessLogs = append(accessLogs, log)
		}

		return c.JSON(http.StatusOK, accessLogs)
	})

	e.Logger.Fatal(e.Start(":80"))
}
