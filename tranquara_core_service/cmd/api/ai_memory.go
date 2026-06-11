package main

import (
	"errors"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/google/uuid"
	"github.com/julienschmidt/httprouter"
	"tranquara.net/internal/data"
)

// ═══════════════════════════════════════════════════════════════════════════
// Public endpoints (require auth)
// ═══════════════════════════════════════════════════════════════════════════

// listAIMemoriesHandler returns all AI memories for the authenticated user.
// GET /v1/ai-memories?category=values (optional category filter)
func (app *application) listAIMemoriesHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := app.GetUserUUIDFromContext(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	category := r.URL.Query().Get("category")

	memories, err := app.models.AIMemory.GetAllByUser(userID, category)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, envolope{
		"memories": memories,
		"total":    len(memories),
	}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// deleteAIMemoryHandler hard-deletes a single AI memory.
// DELETE /v1/ai-memories/:id
// Also calls the AI service to remove the memory from Qdrant.
func (app *application) deleteAIMemoryHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := app.GetUserUUIDFromContext(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	params := httprouter.ParamsFromContext(r.Context())
	memoryIDStr := params.ByName("id")

	memoryID, err := uuid.Parse(memoryIDStr)
	if err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, "Invalid memory ID format")
		return
	}

	// Delete from PostgreSQL
	err = app.models.AIMemory.Delete(memoryID, userID)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			http.NotFound(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	// Delete from Qdrant via AI service (fire-and-forget)
	go app.deleteMemoryFromQdrant(memoryID.String())

	err = app.writeJson(w, http.StatusOK, envolope{"message": "memory deleted"}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// deleteMemoryFromQdrant calls the AI service to remove a memory vector.
func (app *application) deleteMemoryFromQdrant(memoryID string) {
	aiServiceURL := os.Getenv("AI_SERVICE_URL")
	if aiServiceURL == "" {
		aiServiceURL = "http://ai_service:8000"
	}

	url := fmt.Sprintf("%s/api/internal/memory/%s", aiServiceURL, memoryID)

	req, err := http.NewRequest(http.MethodDelete, url, nil)
	if err != nil {
		app.logger.PrintError(err, map[string]string{"context": "delete memory from qdrant"})
		return
	}

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		app.logger.PrintError(err, map[string]string{"context": "delete memory from qdrant"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		app.logger.PrintError(
			fmt.Errorf("qdrant delete returned status %d", resp.StatusCode),
			map[string]string{"memory_id": memoryID},
		)
	}
}

// ═══════════════════════════════════════════════════════════════════════════
// Internal endpoints (called by AI service, protected by internal API key)
// ═══════════════════════════════════════════════════════════════════════════

// internalAuthMiddleware validates the X-Internal-Key header.
func (app *application) internalAuthMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		expectedKey := os.Getenv("INTERNAL_API_KEY")
		if expectedKey == "" {
			app.logger.PrintError(fmt.Errorf("INTERNAL_API_KEY not configured — rejecting request"), nil)
			app.errorResponse(w, r, http.StatusInternalServerError, "Internal API key not configured")
			return
		}

		providedKey := r.Header.Get("X-Internal-Key")
		if providedKey != expectedKey {
			app.errorResponse(w, r, http.StatusUnauthorized, "Invalid internal API key")
			return
		}

		next.ServeHTTP(w, r)
	}
}

// internalGetActiveJournalUsersHandler returns users with recent journal activity and their language preferences.
// GET /v1/internal/active-journal-users?since=2026-03-04T00:00:00Z
func (app *application) internalGetActiveJournalUsersHandler(w http.ResponseWriter, r *http.Request) {
	sinceStr := r.URL.Query().Get("since")
	if sinceStr == "" {
		app.errorResponse(w, r, http.StatusBadRequest, "Missing 'since' query parameter")
		return
	}

	since, err := time.Parse(time.RFC3339, sinceStr)
	if err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, "Invalid 'since' format, use RFC3339")
		return
	}

	users, err := app.models.AIMemory.GetActiveJournalUsersSince(since)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, envolope{"users": users}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// internalBatchCreateMemoriesHandler creates multiple memories for a user.
// POST /v1/internal/ai-memories/batch
// Body: { "user_id": "uuid", "memories": [{"content": "...", "category": "...", "confidence": 0.9}] }
func (app *application) internalBatchCreateMemoriesHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		UserID   string `json:"user_id"`
		Memories []struct {
			Content    string  `json:"content"`
			Category   string  `json:"category"`
			Confidence float64 `json:"confidence"`
		} `json:"memories"`
	}

	err := app.readJson(w, r, &input)
	if err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, err.Error())
		return
	}

	userID, err := uuid.Parse(input.UserID)
	if err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, "Invalid 'user_id' format")
		return
	}

	// Convert to data model
	memories := make([]data.AIMemory, len(input.Memories))
	for i, m := range input.Memories {
		memories[i] = data.AIMemory{
			Content:          m.Content,
			Category:         m.Category,
			Confidence:       m.Confidence,
			SourceJournalIDs: []uuid.UUID{},
		}
	}

	created, err := app.models.AIMemory.BatchCreate(userID, memories)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusCreated, envolope{"created": created}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// internalGetUserJournalsByDateRangeHandler returns a user's journals within a date range.
// GET /v1/internal/user-journals?user_id=<uuid>&date_start=2026-03-01&date_end=2026-03-11
func (app *application) internalGetUserJournalsByDateRangeHandler(w http.ResponseWriter, r *http.Request) {
	userIDStr := r.URL.Query().Get("user_id")
	dateStartStr := r.URL.Query().Get("date_start")
	dateEndStr := r.URL.Query().Get("date_end")

	if userIDStr == "" || dateStartStr == "" || dateEndStr == "" {
		app.errorResponse(w, r, http.StatusBadRequest, "Missing user_id, date_start or date_end")
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, "Invalid user_id format")
		return
	}

	startDate, err := time.Parse("2006-01-02", dateStartStr)
	if err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, "Invalid date_start format (expected YYYY-MM-DD)")
		return
	}

	endDate, err := time.Parse("2006-01-02", dateEndStr)
	if err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, "Invalid date_end format (expected YYYY-MM-DD)")
		return
	}

	// Include the full end day
	endDate = endDate.Add(24*time.Hour - time.Nanosecond)

	journals, err := app.models.UserJournal.GetByDateRange(userID, startDate, endDate)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJson(w, http.StatusOK, envolope{"journals": journals}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
