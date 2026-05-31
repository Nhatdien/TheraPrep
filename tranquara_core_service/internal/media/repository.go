package media

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/google/uuid"
)

// MediaFile represents a media file record in the database
type MediaFile struct {
	ID           string    `json:"id"`
	UserID       string    `json:"user_id"`
	Filename     string    `json:"filename"`
	ContentType  string    `json:"content_type"`
	SizeBytes    int64     `json:"size_bytes"`
	R2Key        string    `json:"r2_key"`
	R2URL        string    `json:"r2_url"`
	UploadStatus string    `json:"upload_status"`
	CreatedAt    time.Time `json:"created_at"`
}

// JournalEntryMedia represents the junction between journal entries and media
type JournalEntryMedia struct {
	ID             string    `json:"id"`
	JournalEntryID string    `json:"journal_entry_id"`
	MediaFileID    string    `json:"media_file_id"`
	SlideIndex     int       `json:"slide_index"`
	Position       int       `json:"position"`
	CreatedAt      time.Time `json:"created_at"`

	// Joined fields (populated on query)
	URL         string `json:"url,omitempty"`
	Filename    string `json:"filename,omitempty"`
	ContentType string `json:"content_type,omitempty"`
	SizeBytes   int64  `json:"size_bytes,omitempty"`
}

// Repository handles database operations for media
type Repository struct {
	db *sql.DB
}

// NewRepository creates a new media repository
func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

// Create creates a new media file record
func (r *Repository) Create(ctx context.Context, mf *MediaFile) error {
	query := `
		INSERT INTO media_files (id, user_id, filename, content_type, size_bytes, r2_key, r2_url, upload_status)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`
	if mf.ID == "" {
		mf.ID = uuid.New().String()
	}

	_, err := r.db.ExecContext(ctx, query,
		mf.ID, mf.UserID, mf.Filename, mf.ContentType,
		mf.SizeBytes, mf.R2Key, mf.R2URL, mf.UploadStatus,
	)
	if err != nil {
		return fmt.Errorf("failed to create media file: %w", err)
	}
	return nil
}

// GetByID retrieves a media file by ID
func (r *Repository) GetByID(ctx context.Context, id string) (*MediaFile, error) {
	query := `
		SELECT id, user_id, filename, content_type, size_bytes, r2_key, r2_url, upload_status, created_at
		FROM media_files WHERE id = $1
	`
	mf := &MediaFile{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&mf.ID, &mf.UserID, &mf.Filename, &mf.ContentType,
		&mf.SizeBytes, &mf.R2Key, &mf.R2URL, &mf.UploadStatus, &mf.CreatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get media file: %w", err)
	}
	return mf, nil
}

// ConfirmUpload marks a media file as confirmed
func (r *Repository) ConfirmUpload(ctx context.Context, id, userID string) error {
	query := `UPDATE media_files SET upload_status = 'confirmed' WHERE id = $1 AND user_id = $2`
	result, err := r.db.ExecContext(ctx, query, id, userID)
	if err != nil {
		return fmt.Errorf("failed to confirm upload: %w", err)
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("media file not found or not owned by user")
	}
	return nil
}

// Delete deletes a media file record (caller should delete from R2 first)
func (r *Repository) Delete(ctx context.Context, id, userID string) error {
	query := `DELETE FROM media_files WHERE id = $1 AND user_id = $2`
	result, err := r.db.ExecContext(ctx, query, id, userID)
	if err != nil {
		return fmt.Errorf("failed to delete media file: %w", err)
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("media file not found or not owned by user")
	}
	return nil
}

// GetByJournalEntryID retrieves all media for a journal entry
func (r *Repository) GetByJournalEntryID(ctx context.Context, journalEntryID string) ([]JournalEntryMedia, error) {
	query := `
		SELECT jem.id, jem.journal_entry_id, jem.media_file_id, jem.slide_index, jem.position, jem.created_at,
			mf.r2_url, mf.filename, mf.content_type, mf.size_bytes
		FROM journal_entry_media jem
		JOIN media_files mf ON jem.media_file_id = mf.id
		WHERE jem.journal_entry_id = $1
		ORDER BY jem.slide_index, jem.position
	`
	rows, err := r.db.QueryContext(ctx, query, journalEntryID)
	if err != nil {
		return nil, fmt.Errorf("failed to get journal media: %w", err)
	}
	defer rows.Close()

	var result []JournalEntryMedia
	for rows.Next() {
		var jem JournalEntryMedia
		err := rows.Scan(
			&jem.ID, &jem.JournalEntryID, &jem.MediaFileID, &jem.SlideIndex, &jem.Position, &jem.CreatedAt,
			&jem.URL, &jem.Filename, &jem.ContentType, &jem.SizeBytes,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan journal media: %w", err)
		}
		result = append(result, jem)
	}
	return result, nil
}

// AttachMediaToJournalEntry links media files to journal entry slides
func (r *Repository) AttachMediaToJournalEntry(ctx context.Context, journalEntryID string, attachments []JournalEntryMedia) error {
	// Delete existing attachments for this journal entry
	_, err := r.db.ExecContext(ctx, `DELETE FROM journal_entry_media WHERE journal_entry_id = $1`, journalEntryID)
	if err != nil {
		return fmt.Errorf("failed to clear existing media attachments: %w", err)
	}

	// Insert new attachments
	query := `
		INSERT INTO journal_entry_media (id, journal_entry_id, media_file_id, slide_index, position)
		VALUES ($1, $2, $3, $4, $5)
	`
	for _, att := range attachments {
		id := att.ID
		if id == "" {
			id = uuid.New().String()
		}
		_, err := r.db.ExecContext(ctx, query, id, journalEntryID, att.MediaFileID, att.SlideIndex, att.Position)
		if err != nil {
			return fmt.Errorf("failed to attach media: %w", err)
		}
	}
	return nil
}

// CleanupPending removes old pending uploads (>1 hour)
func (r *Repository) CleanupPending(ctx context.Context) (int64, error) {
	result, err := r.db.ExecContext(ctx, `
		DELETE FROM media_files 
		WHERE upload_status = 'pending' AND created_at < NOW() - INTERVAL '1 hour'
	`)
	if err != nil {
		return 0, err
	}
	return result.RowsAffected()
}

// GetByIDs retrieves multiple media files by IDs
func (r *Repository) GetByIDs(ctx context.Context, ids []string, userID string) ([]MediaFile, error) {
	if len(ids) == 0 {
		return nil, nil
	}
	query := `
		SELECT id, user_id, filename, content_type, size_bytes, r2_key, r2_url, upload_status, created_at
		FROM media_files WHERE id = ANY($1) AND user_id = $2 AND upload_status = 'confirmed'
	`
	rows, err := r.db.QueryContext(ctx, query, ids, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []MediaFile
	for rows.Next() {
		var mf MediaFile
		err := rows.Scan(&mf.ID, &mf.UserID, &mf.Filename, &mf.ContentType,
			&mf.SizeBytes, &mf.R2Key, &mf.R2URL, &mf.UploadStatus, &mf.CreatedAt)
		if err != nil {
			return nil, err
		}
		result = append(result, mf)
	}
	return result, nil
}