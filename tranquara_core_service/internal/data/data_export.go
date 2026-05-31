package data

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// ExportFile represents the top-level export JSON structure
type ExportFile struct {
	Version    int          `json:"version"`
	ExportedAt time.Time    `json:"exported_at"`
	App        string       `json:"app"`
	User       ExportUser   `json:"user"`
	Data       ExportData   `json:"data"`
	Counts     ExportCounts `json:"counts"`
}

type ExportUser struct {
	Username    string `json:"username"`
	DisplayName string `json:"display_name,omitempty"`
}

type ExportData struct {
	Journals           []*UserJournal           `json:"journals"`
	EmotionLogs        []*EmotionLog            `json:"emotion_logs"`
	LearnedSlideGroups []*UserLearnedSlideGroup `json:"learned_slide_groups"`
	TherapySessions    []*TherapySession        `json:"therapy_sessions"`
	HomeworkItems      []*HomeworkItem          `json:"homework_items"`
	UserInformation    *UserInformation         `json:"user_information,omitempty"`
	UserStreak         *UserStreak              `json:"user_streak,omitempty"`
}

type ExportCounts struct {
	Journals           int `json:"journals"`
	EmotionLogs        int `json:"emotion_logs"`
	LearnedSlideGroups int `json:"learned_slide_groups"`
	TherapySessions    int `json:"therapy_sessions"`
	HomeworkItems      int `json:"homework_items"`
}

type DataExportModel struct {
	DB *sql.DB
}

// ExportAll retrieves all user data and assembles into ExportFile
func (m *DataExportModel) ExportAll(userID uuid.UUID, username string) (*ExportFile, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	export := &ExportFile{
		Version:    1,
		ExportedAt: time.Now().UTC(),
		App:        "tranquara",
		User: ExportUser{
			Username: username,
		},
	}

	// Fetch journals
	journals, err := m.getJournals(ctx, userID)
	if err != nil {
		return nil, err
	}
	export.Data.Journals = journals
	export.Counts.Journals = len(journals)

	// Fetch emotion logs
	emotions, err := m.getEmotionLogs(ctx, userID)
	if err != nil {
		return nil, err
	}
	export.Data.EmotionLogs = emotions
	export.Counts.EmotionLogs = len(emotions)

	// Fetch learned slide groups
	learned, err := m.getLearnedSlideGroups(ctx, userID)
	if err != nil {
		return nil, err
	}
	export.Data.LearnedSlideGroups = learned
	export.Counts.LearnedSlideGroups = len(learned)

	// Fetch therapy sessions
	sessions, err := m.getTherapySessions(ctx, userID)
	if err != nil {
		return nil, err
	}
	export.Data.TherapySessions = sessions
	export.Counts.TherapySessions = len(sessions)

	// Fetch homework items
	homework, err := m.getHomeworkItems(ctx, userID)
	if err != nil {
		return nil, err
	}
	export.Data.HomeworkItems = homework
	export.Counts.HomeworkItems = len(homework)

	// Fetch user information (single record — ok if missing)
	info, _ := m.getUserInformation(ctx, userID)
	export.Data.UserInformation = info

	// Fetch user streak (single record — ok if missing)
	streak, _ := m.getUserStreak(ctx, userID)
	export.Data.UserStreak = streak

	return export, nil
}

func (m *DataExportModel) getJournals(ctx context.Context, userID uuid.UUID) ([]*UserJournal, error) {
	query := `
		SELECT id, user_id, collection_id, title, content, content_html,
		       mood_score, mood_label, sleep_score, created_at, updated_at
		FROM user_journals
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := m.DB.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var journals []*UserJournal
	for rows.Next() {
		var j UserJournal
		err = rows.Scan(
			&j.ID, &j.UserID, &j.CollectionID, &j.Title, &j.Content,
			&j.ContentHTML, &j.MoodScore, &j.MoodLabel, &j.SleepScore,
			&j.CreatedAt, &j.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		journals = append(journals, &j)
	}

	return journals, rows.Err()
}

func (m *DataExportModel) getEmotionLogs(ctx context.Context, userID uuid.UUID) ([]*EmotionLog, error) {
	query := `
		SELECT id, user_id, emotion, source, context, created_at
		FROM emotion_logs
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := m.DB.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var logs []*EmotionLog
	for rows.Next() {
		var e EmotionLog
		err = rows.Scan(&e.ID, &e.UserID, &e.Emotion, &e.Source, &e.Context, &e.CreatedAt)
		if err != nil {
			return nil, err
		}
		logs = append(logs, &e)
	}

	return logs, rows.Err()
}

func (m *DataExportModel) getLearnedSlideGroups(ctx context.Context, userID uuid.UUID) ([]*UserLearnedSlideGroup, error) {
	query := `
		SELECT id, user_id, collection_id, slide_group_id, completed_at
		FROM user_learned_slide_groups
		WHERE user_id = $1
		ORDER BY completed_at DESC
	`

	rows, err := m.DB.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*UserLearnedSlideGroup
	for rows.Next() {
		var l UserLearnedSlideGroup
		err = rows.Scan(&l.ID, &l.UserID, &l.CollectionID, &l.SlideGroupID, &l.CompletedAt)
		if err != nil {
			return nil, err
		}
		results = append(results, &l)
	}

	return results, rows.Err()
}

func (m *DataExportModel) getTherapySessions(ctx context.Context, userID uuid.UUID) ([]*TherapySession, error) {
	query := `
		SELECT id, user_id, session_date, status, mood_before, talking_points, session_priority,
		       prep_pack_id, mood_after, key_takeaways, session_rating, created_at, updated_at
		FROM therapy_sessions
		WHERE user_id = $1
		ORDER BY COALESCE(session_date, created_at) DESC
	`

	rows, err := m.DB.QueryContext(ctx, query, userID.String())
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var sessions []*TherapySession
	for rows.Next() {
		var s TherapySession
		err = rows.Scan(
			&s.ID, &s.UserID, &s.SessionDate, &s.Status, &s.MoodBefore,
			&s.TalkingPoints, &s.SessionPriority, &s.PrepPackID,
			&s.MoodAfter, &s.KeyTakeaways, &s.SessionRating,
			&s.CreatedAt, &s.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		sessions = append(sessions, &s)
	}

	return sessions, rows.Err()
}

func (m *DataExportModel) getHomeworkItems(ctx context.Context, userID uuid.UUID) ([]*HomeworkItem, error) {
	query := `
		SELECT id, session_id, user_id, content, completed, completed_at, created_at
		FROM homework_items
		WHERE user_id = $1
		ORDER BY created_at ASC
	`

	rows, err := m.DB.QueryContext(ctx, query, userID.String())
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []*HomeworkItem
	for rows.Next() {
		var item HomeworkItem
		err = rows.Scan(
			&item.ID, &item.SessionID, &item.UserID, &item.Content,
			&item.Completed, &item.CompletedAt, &item.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		items = append(items, &item)
	}

	return items, rows.Err()
}

func (m *DataExportModel) getUserInformation(ctx context.Context, userID uuid.UUID) (*UserInformation, error) {
	query := `
		SELECT user_id, email, username, oauth_provider, name, age_range, gender, kyc_answers, settings, created_at, updated_at
		FROM user_informations
		WHERE user_id = $1
	`

	var info UserInformation
	var kycRaw []byte
	var settingRaw []byte

	err := m.DB.QueryRowContext(ctx, query, userID).Scan(
		&info.UserID, &info.Email, &info.Username, &info.OAuthProvider,
		&info.Name, &info.AgeRange, &info.Gender,
		&kycRaw, &settingRaw,
		&info.CreatedAt, &info.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	if err := json.Unmarshal(kycRaw, &info.KYCAnswers); err != nil {
		return nil, err
	}
	if err := json.Unmarshal(settingRaw, &info.Settings); err != nil {
		return nil, err
	}

	return &info, nil
}

func (m *DataExportModel) getUserStreak(ctx context.Context, userID uuid.UUID) (*UserStreak, error) {
	query := `
		SELECT user_id, current_streak, longest_streak, last_active, total_entries, updated_at
		FROM user_streaks
		WHERE user_id = $1
	`

	var streak UserStreak
	err := m.DB.QueryRowContext(ctx, query, userID).Scan(
		&streak.UserId, &streak.CurrentStreak,
		&streak.LongestStreak, &streak.LastActive,
		&streak.TotalEntries, &streak.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &streak, nil
}
