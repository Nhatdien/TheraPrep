package data

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/google/uuid"
)

// ImportResult tracks the outcome of an import operation
type ImportResult struct {
	Imported struct {
		Journals           int `json:"journals"`
		EmotionLogs        int `json:"emotion_logs"`
		LearnedSlideGroups int `json:"learned_slide_groups"`
		TherapySessions    int `json:"therapy_sessions"`
		HomeworkItems      int `json:"homework_items"`
	} `json:"imported"`
	Skipped struct {
		Journals           int `json:"journals"`
		EmotionLogs        int `json:"emotion_logs"`
		LearnedSlideGroups int `json:"learned_slide_groups"`
		TherapySessions    int `json:"therapy_sessions"`
		HomeworkItems      int `json:"homework_items"`
	} `json:"skipped"`
	Errors []string `json:"errors,omitempty"`
}

type DataImportModel struct {
	DB *sql.DB
}

// ImportAll imports user data from an ExportFile, using upsert logic
func (m *DataImportModel) ImportAll(userID uuid.UUID, exportFile *ExportFile) (*ImportResult, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	result := &ImportResult{}

	// Import journals
	for _, j := range exportFile.Data.Journals {
		if j == nil {
			continue
		}
		_, err := m.upsertJournal(ctx, userID, j)
		if err != nil {
			result.Errors = append(result.Errors, fmt.Sprintf("journal: %v", err))
			result.Skipped.Journals++
		} else {
			result.Imported.Journals++
		}
	}

	// Import emotion logs
	for _, e := range exportFile.Data.EmotionLogs {
		if e == nil {
			continue
		}
		err := m.insertEmotionLog(ctx, userID, e)
		if err != nil {
			result.Errors = append(result.Errors, fmt.Sprintf("emotion_log: %v", err))
			result.Skipped.EmotionLogs++
		} else {
			result.Imported.EmotionLogs++
		}
	}

	// Import learned slide groups
	for _, l := range exportFile.Data.LearnedSlideGroups {
		if l == nil {
			continue
		}
		err := m.upsertLearnedSlideGroup(ctx, userID, l)
		if err != nil {
			result.Errors = append(result.Errors, fmt.Sprintf("learned_slide_group: %v", err))
			result.Skipped.LearnedSlideGroups++
		} else {
			result.Imported.LearnedSlideGroups++
		}
	}

	// Import therapy sessions with homework
	for _, s := range exportFile.Data.TherapySessions {
		if s == nil {
			continue
		}
		newID, err := m.upsertTherapySession(ctx, userID, s)
		if err != nil {
			result.Errors = append(result.Errors, fmt.Sprintf("therapy_session: %v", err))
			result.Skipped.TherapySessions++
			continue
		}
		result.Imported.TherapySessions++

		// Import associated homework items
		if s.ID != uuid.Nil {
			for _, hw := range exportFile.Data.HomeworkItems {
				if hw == nil {
					continue
				}
				// Only import homework for sessions we just imported
				if hw.SessionID == s.ID {
					hw.SessionID = newID
					err := m.insertHomeworkItem(ctx, userID, hw)
					if err != nil {
						result.Errors = append(result.Errors, fmt.Sprintf("homework_item: %v", err))
						result.Skipped.HomeworkItems++
					} else {
						result.Imported.HomeworkItems++
					}
				}
			}
		}
	}

	// Import homework items that weren't associated with a specific session above
	for _, hw := range exportFile.Data.HomeworkItems {
		if hw == nil {
			continue
		}
		// Skip if already imported (matched by session above)
		alreadyImported := false
		for _, s := range exportFile.Data.TherapySessions {
			if s != nil && hw.SessionID == s.ID {
				alreadyImported = true
				break
			}
		}
		if alreadyImported {
			continue
		}
		err := m.insertHomeworkItem(ctx, userID, hw)
		if err != nil {
			result.Errors = append(result.Errors, fmt.Sprintf("homework_item: %v", err))
			result.Skipped.HomeworkItems++
		} else {
			result.Imported.HomeworkItems++
		}
	}

	return result, nil
}

func (m *DataImportModel) upsertJournal(ctx context.Context, userID uuid.UUID, j *UserJournal) (*UserJournal, error) {
	// Generate new ID to avoid collision with existing records
	newID := uuid.New()

	query := `
		INSERT INTO user_journals (id, user_id, collection_id, title, content, content_html, mood_score, mood_label, sleep_score, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, user_id, collection_id, title, content, content_html, mood_score, mood_label, sleep_score, created_at, updated_at
	`

	var imported UserJournal
	err := m.DB.QueryRowContext(ctx, query,
		newID, userID, j.CollectionID, j.Title, j.Content,
		j.ContentHTML, j.MoodScore, j.MoodLabel, j.SleepScore,
		j.CreatedAt,
	).Scan(
		&imported.ID, &imported.UserID, &imported.CollectionID,
		&imported.Title, &imported.Content, &imported.ContentHTML,
		&imported.MoodScore, &imported.MoodLabel, &imported.SleepScore,
		&imported.CreatedAt, &imported.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &imported, nil
}

func (m *DataImportModel) insertEmotionLog(ctx context.Context, userID uuid.UUID, e *EmotionLog) error {
	query := `
		INSERT INTO emotion_logs (user_id, emotion, source, context, created_at)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id
	`
	var id uuid.UUID
	return m.DB.QueryRowContext(ctx, query,
		userID, e.Emotion, e.Source, e.Context, e.CreatedAt,
	).Scan(&id)
}

func (m *DataImportModel) upsertLearnedSlideGroup(ctx context.Context, userID uuid.UUID, l *UserLearnedSlideGroup) error {
	query := `
		INSERT INTO user_learned_slide_groups (user_id, collection_id, slide_group_id, completed_at)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (user_id, collection_id, slide_group_id) DO UPDATE SET
			completed_at = EXCLUDED.completed_at
		RETURNING id
	`
	var id int64
	return m.DB.QueryRowContext(ctx, query,
		userID, l.CollectionID, l.SlideGroupID, l.CompletedAt,
	).Scan(&id)
}

func (m *DataImportModel) upsertTherapySession(ctx context.Context, userID uuid.UUID, s *TherapySession) (uuid.UUID, error) {
	// Generate new ID to avoid collision
	newID := uuid.New()

	query := `
		INSERT INTO therapy_sessions (id, user_id, session_date, status, mood_before, talking_points, session_priority, prep_pack_id, mood_after, key_takeaways, session_rating, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
		RETURNING id
	`

	err := m.DB.QueryRowContext(ctx, query,
		newID, userID.String(), s.SessionDate, s.Status, s.MoodBefore,
		s.TalkingPoints, s.SessionPriority, s.PrepPackID,
		s.MoodAfter, s.KeyTakeaways, s.SessionRating, s.CreatedAt,
	).Scan(&newID)

	if err != nil {
		return uuid.Nil, err
	}
	return newID, nil
}

func (m *DataImportModel) insertHomeworkItem(ctx context.Context, userID uuid.UUID, hw *HomeworkItem) error {
	query := `
		INSERT INTO homework_items (session_id, user_id, content, completed, completed_at, created_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id
	`
	var id uuid.UUID
	return m.DB.QueryRowContext(ctx, query,
		hw.SessionID, userID.String(), hw.Content, hw.Completed, hw.CompletedAt, hw.CreatedAt,
	).Scan(&id)
}

// ValidateExportFile checks that the import file is a valid Tranquara export
func ValidateExportFile(export *ExportFile) error {
	if export == nil {
		return fmt.Errorf("import file is empty")
	}
	if export.App != "tranquara" {
		return fmt.Errorf("invalid export file: app field must be 'tranquara', got '%s'", export.App)
	}
	if export.Version < 1 || export.Version > 2 {
		return fmt.Errorf("unsupported export version: %d", export.Version)
	}
	return nil
}