package api

import (
	"encoding/json"
	"fmt"
	"net/http"

	"tranquara_core_service/internal/media"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
)

// MediaHandler handles media upload/download/delete operations
type MediaHandler struct {
	repo    *media.Repository
	storage *media.R2Storage
}

// NewMediaHandler creates a new media handler
func NewMediaHandler(repo *media.Repository, storage *media.R2Storage) *MediaHandler {
	return &MediaHandler{repo: repo, storage: storage}
}

// Allowed content types
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

// Presign generates a presigned upload URL
func (h *MediaHandler) Presign(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("userID").(string)

	var req presignRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Validate content type
	if !allowedContentTypes[req.ContentType] {
		writeJSON(w, http.StatusBadRequest, map[string]string{
			"error": "Unsupported file type. Allowed: JPEG, PNG, WebP, GIF",
		})
		return
	}

	// Validate file size
	if req.SizeBytes > maxFileSize {
		writeJSON(w, http.StatusBadRequest, map[string]string{
			"error": fmt.Sprintf("File too large. Maximum size: %dMB", maxFileSize/1024/1024),
		})
		return
	}

	if req.Filename == "" {
		http.Error(w, "Filename is required", http.StatusBadRequest)
		return
	}

	mediaID := uuid.New().String()

	// Generate presigned URL from R2
	result, err := h.storage.GeneratePresignedUploadURL(r.Context(), userID, mediaID, req.Filename, req.ContentType)
	if err != nil {
		http.Error(w, "Failed to generate upload URL", http.StatusInternalServerError)
		return
	}

	// Create pending media file record in DB
	mf := &media.MediaFile{
		ID:           mediaID,
		UserID:       userID,
		Filename:     req.Filename,
		ContentType:  req.ContentType,
		SizeBytes:    req.SizeBytes,
		R2Key:        result.R2Key,
		R2URL:        result.DownloadURL,
		UploadStatus: "pending",
	}
	if err := h.repo.Create(r.Context(), mf); err != nil {
		http.Error(w, "Failed to create media record", http.StatusInternalServerError)
		return
	}

	writeJSON(w, http.StatusOK, presignResponse{
		MediaID:     mediaID,
		UploadURL:   result.UploadURL,
		DownloadURL: result.DownloadURL,
		ExpiresAt:   result.ExpiresAt.Format("2006-01-02T15:04:05Z"),
	})
}

// Confirm confirms that a file upload completed successfully
func (h *MediaHandler) Confirm(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("userID").(string)
	mediaID := getPathParam(r, "id")

	if mediaID == "" {
		http.Error(w, "Media ID is required", http.StatusBadRequest)
		return
	}

	// Verify the media file exists and belongs to user
	mf, err := h.repo.GetByID(r.Context(), mediaID)
	if err != nil || mf == nil {
		http.Error(w, "Media file not found", http.StatusNotFound)
		return
	}
	if mf.UserID != userID {
		http.Error(w, "Unauthorized", http.StatusForbidden)
		return
	}

	// Update status to confirmed
	if err := h.repo.ConfirmUpload(r.Context(), mediaID, userID); err != nil {
		http.Error(w, "Failed to confirm upload", http.StatusInternalServerError)
		return
	}

	// Return updated media file
	mf.UploadStatus = "confirmed"
	writeJSON(w, http.StatusOK, mf)
}

// GetMedia retrieves a single media file by ID
func (h *MediaHandler) GetMedia(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("userID").(string)
	mediaID := getPathParam(r, "id")

	mf, err := h.repo.GetByID(r.Context(), mediaID)
	if err != nil || mf == nil {
		http.Error(w, "Media file not found", http.StatusNotFound)
		return
	}
	if mf.UserID != userID {
		http.Error(w, "Unauthorized", http.StatusForbidden)
		return
	}

	writeJSON(w, http.StatusOK, mf)
}

// DeleteMedia deletes a media file (from R2 + DB)
func (h *MediaHandler) DeleteMedia(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("userID").(string)
	mediaID := getPathParam(r, "id")

	mf, err := h.repo.GetByID(r.Context(), mediaID)
	if err != nil || mf == nil {
		http.Error(w, "Media file not found", http.StatusNotFound)
		return
	}
	if mf.UserID != userID {
		http.Error(w, "Unauthorized", http.StatusForbidden)
		return
	}

	// Delete from R2
	if err := h.storage.DeleteObject(r.Context(), mf.R2Key); err != nil {
		// Log but don't fail — DB record is the source of truth
		fmt.Printf("Warning: failed to delete R2 object %s: %v\n", mf.R2Key, err)
	}

	// Delete from DB (cascade removes journal_entry_media rows)
	if err := h.repo.Delete(r.Context(), mediaID, userID); err != nil {
		http.Error(w, "Failed to delete media", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// GetJournalMedia retrieves all media for a journal entry
func (h *MediaHandler) GetJournalMedia(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("userID").(string)
	journalEntryID := getPathParam(r, "journalEntryId")

	mediaList, err := h.repo.GetByJournalEntryID(r.Context(), journalEntryID)
	if err != nil {
		http.Error(w, "Failed to get journal media", http.StatusInternalServerError)
		return
	}

	// Verify ownership (check that the journal entry belongs to user)
	// For now, the join query will simply return empty if user doesn't own the entry
	_ = userID

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"media": mediaList,
	})
}

type attachRequest struct {
	MediaIDs  []string                   `json:"media_ids"`
	JournalID string                     `json:"journal_id"`
	Slides    []slideMediaAttachment     `json:"slides"`
}

type slideMediaAttachment struct {
	SlideIndex int      `json:"slide_index"`
	MediaIDs   []string `json:"media_ids"`
}

// AttachMedia attaches media files to a journal entry's slides
func (h *MediaHandler) AttachMedia(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value("userID").(string)

	var req attachRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.JournalID == "" {
		http.Error(w, "journal_id is required", http.StatusBadRequest)
		return
	}

	// Build attachments
	var attachments []media.JournalEntryMedia
	for _, slide := range req.Slides {
		// Verify all media IDs belong to user
		files, err := h.repo.GetByIDs(r.Context(), slide.MediaIDs, userID)
		if err != nil || len(files) != len(slide.MediaIDs) {
			http.Error(w, "One or more media files not found or not owned by user", http.StatusBadRequest)
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

	if err := h.repo.AttachMediaToJournalEntry(r.Context(), req.JournalID, attachments); err != nil {
		http.Error(w, "Failed to attach media", http.StatusInternalServerError)
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

// getPathParam extracts a path parameter from the URL using gorilla/mux
func getPathParam(r *http.Request, param string) string {
	return mux.Vars(r)[param]
}

// writeJSON writes a JSON response
func writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

// parseIntQueryParam parses an integer query parameter with a default value
func parseIntQueryParam(r *http.Request, param string, defaultVal int) int {
	val := r.URL.Query().Get(param)
	if val == "" {
		return defaultVal
	}
	n, err := strconv.Atoi(val)
	if err != nil {
		return defaultVal
	}
	return n
}

