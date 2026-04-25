package data

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
)

// UserCustomTemplate holds the user-defined daily journal template (one per user).
type UserCustomTemplate struct {
	ID          uuid.UUID       `json:"id"`
	UserID      uuid.UUID       `json:"user_id"`
	Title       string          `json:"title"`
	SlideGroups json.RawMessage `json:"slide_groups"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
}

// UserCustomTemplateModel wraps the database connection.
type UserCustomTemplateModel struct {
	DB *sql.DB
}

// GetByUserId returns the custom template for the given user.
// Returns ErrRecordNotFound if the user has not created one yet.
func (m UserCustomTemplateModel) GetByUserId(userID uuid.UUID) (*UserCustomTemplate, error) {
	query := `
		SELECT id, user_id, title, slide_groups, created_at, updated_at
		FROM user_custom_templates
		WHERE user_id = $1
	`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var t UserCustomTemplate
	err := m.DB.QueryRowContext(ctx, query, userID).Scan(
		&t.ID,
		&t.UserID,
		&t.Title,
		&t.SlideGroups,
		&t.CreatedAt,
		&t.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrRecordNotFound
		}
		return nil, err
	}

	return &t, nil
}

// Upsert creates or fully replaces the user's custom template.
// Only one template per user is allowed (enforced by UNIQUE(user_id)).
func (m UserCustomTemplateModel) Upsert(userID uuid.UUID, title string, slideGroups json.RawMessage) (*UserCustomTemplate, error) {
	query := `
		INSERT INTO user_custom_templates (user_id, title, slide_groups, created_at, updated_at)
		VALUES ($1, $2, $3, NOW(), NOW())
		RETURNING id, user_id, title, slide_groups, created_at, updated_at
	`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var t UserCustomTemplate
	err := m.DB.QueryRowContext(ctx, query, userID, title, slideGroups).Scan(
		&t.ID,
		&t.UserID,
		&t.Title,
		&t.SlideGroups,
		&t.CreatedAt,
		&t.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &t, nil
}
