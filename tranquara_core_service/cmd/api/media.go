package main

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/google/uuid"
	"github.com/julienschmidt/httprouter"

	"tranquara.net/internal/media"
)

// Allowed content types for media upload
var allowedContentTypes = map[string]bool{
	"image/jpeg": true,
	"image/png":  true,
	"image/webp": true,
	"image/gif":  true,
}

const maxFileSize = 10 * 1024 * 1024 // 10MB

type presignRequest struct {
	Filename    string `json:"filename"`
	ContentType string `json:"content_type"`
	SizeBytes   int64  `json:"size_bytes"`
}

type presignResponse struct {
	MediaID     string `json:"media_id"`
	UploadURL   string `json:"upload_url"`
	DownloadURL string `json:"download_url"`
	ExpiresAt   string `json:"expires_at"`
}

type attachRequest struct {
	JournalID string                 `json:"journal_id"`
	Slides    []slideMediaAttachment `json:"slides"`
}

type slideMediaAttachment struct {
	SlideIndex int      `json:"slide_index"`
	MediaIDs   []string `json:"media_ids"`
}

// Presign generates a presigned upload URL
func (app *application) mediaPresignHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := app.GetUserUUIDFromContext(r.Context())
	if err != nil {
		app.errorResponse(w, r, http.StatusUnauthorized, "Unauthorized")
		return
	}

	var req presignRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate content type
	if !allowedContentTypes[req.ContentType] {
		app.errorResponse(w, r, http.StatusBadRequest, "Unsupported file type. Allowed: JPEG, PNG, WebP, GIF")
		return
	}

	// Validate file size
	if req.SizeBytes > maxFileSize {
		app.errorResponse(w, r, http.StatusBadRequest, fmt.Sprintf("File too large. Maximum size: %dMB", maxFileSize/1024/1024))
		return
	}

	if req.Filename == "" {
		app.errorResponse(w, r, http.StatusBadRequest, "Filename is required")
		return
	}

	mediaID := uuid.New().String()

	// Generate presigned URL from R2
	result, err := app.r2Storage.GeneratePresignedUploadURL(r.Context(), userID.String(), mediaID, req.Filename, req.ContentType)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Create pending media file record in DB
	mf := &media.MediaFile{
		ID:           mediaID,
		UserID:       userID.String(),
		Filename:     req.Filename,
		ContentType:  req.ContentType,
		SizeBytes:    req.SizeBytes,
		R2Key:        result.R2Key,
		R2URL:        result.DownloadURL,
		UploadStatus: "pending",
	}
	if err := app.mediaRepo.Create(r.Context(), mf); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, presignResponse{
		MediaID:     mediaID,
		UploadURL:   result.UploadURL,
		DownloadURL: result.DownloadURL,
		ExpiresAt:   result.ExpiresAt.Format("2006-01-02T15:04:05Z"),
	}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// Confirm confirms that a file upload completed successfully
func (app *application) mediaConfirmHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := app.GetUserUUIDFromContext(r.Context())
	if err != nil {
		app.errorResponse(w, r, http.StatusUnauthorized, "Unauthorized")
		return
	}

	params := httprouter.ParamsFromContext(r.Context())
	mediaID := params.ByName("id")
	if mediaID == "" {
		app.errorResponse(w, r, http.StatusBadRequest, "Media ID is required")
		return
	}

	// Verify the media file exists and belongs to user
	mf, err := app.mediaRepo.GetByID(r.Context(), mediaID)
	if err != nil || mf == nil {
		app.errorResponse(w, r, http.StatusNotFound, "Media file not found")
		return
	}
	if mf.UserID != userID.String() {
		app.errorResponse(w, r, http.StatusForbidden, "Unauthorized")
		return
	}

	// Update status to confirmed
	if err := app.mediaRepo.ConfirmUpload(r.Context(), mediaID, userID.String()); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	mf.UploadStatus = "confirmed"
	err = app.writeJson(w, http.StatusOK, mf, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// GetMedia retrieves a single media file by ID
func (app *application) getMediaHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := app.GetUserUUIDFromContext(r.Context())
	if err != nil {
		app.errorResponse(w, r, http.StatusUnauthorized, "Unauthorized")
		return
	}

	params := httprouter.ParamsFromContext(r.Context())
	mediaID := params.ByName("id")

	mf, err := app.mediaRepo.GetByID(r.Context(), mediaID)
	if err != nil || mf == nil {
		app.errorResponse(w, r, http.StatusNotFound, "Media file not found")
		return
	}
	if mf.UserID != userID.String() {
		app.errorResponse(w, r, http.StatusForbidden, "Unauthorized")
		return
	}

	err = app.writeJson(w, http.StatusOK, mf, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// DeleteMedia deletes a media file (from R2 + DB)
func (app *application) deleteMediaHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := app.GetUserUUIDFromContext(r.Context())
	if err != nil {
		app.errorResponse(w, r, http.StatusUnauthorized, "Unauthorized")
		return
	}

	params := httprouter.ParamsFromContext(r.Context())
	mediaID := params.ByName("id")

	mf, err := app.mediaRepo.GetByID(r.Context(), mediaID)
	if err != nil || mf == nil {
		app.errorResponse(w, r, http.StatusNotFound, "Media file not found")
		return
	}
	if mf.UserID != userID.String() {
		app.errorResponse(w, r, http.StatusForbidden, "Unauthorized")
		return
	}

	// Delete from R2
	if err := app.r2Storage.DeleteObject(r.Context(), mf.R2Key); err != nil {
		// Log but don't fail — DB record is the source of truth
		fmt.Printf("Warning: failed to delete R2 object %s: %v\n", mf.R2Key, err)
	}

	// Delete from DB (cascade removes journal_entry_media rows)
	if err := app.mediaRepo.Delete(r.Context(), mediaID, userID.String()); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// GetJournalMedia retrieves all media for a journal entry
func (app *application) getJournalMediaHandler(w http.ResponseWriter, r *http.Request) {
	params := httprouter.ParamsFromContext(r.Context())
	journalEntryID := params.ByName("journalEntryId")

	mediaList, err := app.mediaRepo.GetByJournalEntryID(r.Context(), journalEntryID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, map[string]interface{}{
		"media": mediaList,
	}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// AttachMedia attaches media files to a journal entry's slides
func (app *application) attachMediaHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := app.GetUserUUIDFromContext(r.Context())
	if err != nil {
		app.errorResponse(w, r, http.StatusUnauthorized, "Unauthorized")
		return
	}

	var req attachRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, "Invalid request body")
		return
	}

	if req.JournalID == "" {
		app.errorResponse(w, r, http.StatusBadRequest, "journal_id is required")
		return
	}

	// Build attachments
	var attachments []media.JournalEntryMedia
	for _, slide := range req.Slides {
		// Verify all media IDs belong to user
		files, err := app.mediaRepo.GetByIDs(r.Context(), slide.MediaIDs, userID.String())
		if err != nil || len(files) != len(slide.MediaIDs) {
			app.errorResponse(w, r, http.StatusBadRequest, "One or more media files not found or not owned by user")
			return
		}

		for pos, mediaID := range slide.MediaIDs {
			attachments = append(attachments, media.JournalEntryMedia{
				JournalEntryID: req.JournalID,
				MediaFileID:    mediaID,
				SlideIndex:     slide.SlideIndex,
				Position:      pos,
			})
		}
	}

	if err := app.mediaRepo.AttachMediaToJournalEntry(r.Context(), req.JournalID, attachments); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, map[string]string{"status": "ok"}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}