# 11. Data Import/Export — Technical Specification

## 🏗️ Architecture Overview

```
┌──────────────────┐     GET /v1/data-export      ┌──────────────┐
│   Frontend       │ ────────────────────────────► │   Backend    │
│   (Nuxt/Vue)     │ ◄──────────────────────────── │   (Go)       │
│                  │     JSON file download         │              │
│                  │                                │              │
│   useDataExport  │     POST /v1/data-import      │  Queries:    │
│   useDataImport  │ ────────────────────────────► │  - journals  │
│                  │ ◄──────────────────────────── │  - emotions  │
│                  │     Import summary             │  - learned   │
└──────────────────┘                                │  - sessions  │
                                                    │  - homework  │
                                                    │  - streaks   │
                                                    │  - memories  │
                                                    └──────────────┘
```

## 📡 Export JSON Format

### Version 1 Structure

```json
{
  "version": 1,
  "exported_at": "2026-05-31T09:00:00Z",
  "app": "tranquara",
  "user": {
    "username": "john_doe",
    "display_name": "John"
  },
  "data": {
    "journals": [
      {
        "id": "uuid",
        "title": "My Journal Entry",
        "content": "{ ... tip-tap json ... }",
        "content_html": "<p>...</p>",
        "mood_score": 7,
        "mood_label": "Sunny",
        "sleep_score": 80,
        "collection_id": "uuid | null",
        "created_at": "2026-01-15T10:30:00Z",
        "updated_at": "2026-01-15T10:30:00Z"
      }
    ],
    "emotion_logs": [
      {
        "id": "uuid",
        "emotion": "happy",
        "source": "journal",
        "context": "...",
        "created_at": "2026-01-15T10:30:00Z"
      }
    ],
    "learned_slide_groups": [
      {
        "id": "uuid",
        "collection_id": "uuid",
        "slide_group_id": "sg_001",
        "completed_at": "2026-01-15T10:30:00Z"
      }
    ],
    "therapy_sessions": [
      {
        "id": "uuid",
        "title": "First Therapy",
        "date": "2026-01-20",
        "notes": "...",
        "status": "completed",
        "created_at": "2026-01-20T10:00:00Z"
      }
    ],
    "homework_items": [
      {
        "id": "uuid",
        "session_id": "uuid",
        "description": "Practice breathing",
        "is_completed": false,
        "created_at": "2026-01-20T10:00:00Z"
      }
    ],
    "prep_packs": [
      {
        "id": "uuid",
        "session_id": "uuid",
        "content": "{ ... json ... }",
        "created_at": "2026-01-20T10:00:00Z"
      }
    ],
    "user_information": {
      "display_name": "John",
      "age_range": "25-34",
      "goals": ["anxiety", "sleep"],
      "preferences": {}
    },
    "user_streak": {
      "current_streak": 5,
      "longest_streak": 12,
      "last_active_date": "2026-05-30"
    }
  },
  "counts": {
    "journals": 42,
    "emotion_logs": 128,
    "learned_slide_groups": 15,
    "therapy_sessions": 3,
    "homework_items": 8,
    "prep_packs": 2
  }
}
```

---

## 🔧 Backend Implementation (Go)

### 1. Data Export Model

**File:** `internal/data/data_export.go`

```go
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
    Version    int            `json:"version"`
    ExportedAt time.Time      `json:"exported_at"`
    App        string         `json:"app"`
    User       ExportUser     `json:"user"`
    Data       ExportData     `json:"data"`
    Counts     ExportCounts   `json:"counts"`
}

type ExportUser struct {
    Username    string  `json:"username"`
    DisplayName string  `json:"display_name,omitempty"`
}

type ExportData struct {
    Journals            []*UserJournal            `json:"journals"`
    EmotionLogs         []*EmotionLog             `json:"emotion_logs"`
    LearnedSlideGroups  []*UserLearnedSlideGroup  `json:"learned_slide_groups"`
    TherapySessions     []*TherapySession         `json:"therapy_sessions"`
    HomeworkItems       []*HomeworkItem           `json:"homework_items"`
    PrepPacks           []*PrepPack               `json:"prep_packs"`
    UserInformation     *UserInformation          `json:"user_information,omitempty"`
    UserStreak          *UserStreak               `json:"user_streak,omitempty"`
}

type ExportCounts struct {
    Journals           int `json:"journals"`
    EmotionLogs        int `json:"emotion_logs"`
    LearnedSlideGroups int `json:"learned_slide_groups"`
    TherapySessions    int `json:"therapy_sessions"`
    HomeworkItems      int `json:"homework_items"`
    PrepPacks          int `json:"prep_packs"`
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

    // Fetch journals (reuse existing GetList — no pagination, get all)
    journals, err := m.getJournals(ctx, userID)
    if err != nil {
        return nil, err
    }
    export.Data.Journals = journals
    export.Counts.Journals = len(journals)

    // Fetch emotion logs (all, no date filter)
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

    // Fetch prep packs
    packs, err := m.getPrepPacks(ctx, userID)
    if err != nil {
        return nil, err
    }
    export.Data.PrepPacks = packs
    export.Counts.PrepPacks = len(packs)

    // Fetch user information (single record)
    info, _ := m.getUserInformation(ctx, userID)
    export.Data.UserInformation = info

    // Fetch user streak
    streak, _ := m.getUserStreak(ctx, userID)
    export.Data.UserStreak = streak

    return export, nil
}
```

**Key implementation notes:**
- Mỗi `get*` method query riêng, dùng `context` chung với timeout 15s
- Query trực tiếp từ DB tables, **không** gọi qua models khác (để tránh circular dependencies)
- `user_information` và `user_streak` là single records, dùng `/_` cho error (không fail export nếu missing)

### 2. Data Import Model

**File:** `internal/data/data_import.go`

```go
package data

import (
    "context"
    "encoding/json"
    "fmt"
    "time"

    "github.com/google/uuid"
)

// ImportConflictResolution defines how to handle existing records
type ImportConflictResolution string

const (
    ConflictSkip      ImportConflictResolution = "skip"
    ConflictOverwrite ImportConflictResolution = "overwrite"
)

// ImportRequest is the parsed request body
type ImportRequest struct {
    ConflictMode ImportConflictResolution `json:"conflict_mode"`
    Data         json.RawMessage          `json:"data"` // The ExportFile JSON
}

// ImportSummary reports what was imported
type ImportSummary struct {
    Journals            ImportResult `json:"journals"`
    EmotionLogs         ImportResult `json:"emotion_logs"`
    LearnedSlideGroups  ImportResult `json:"learned_slide_groups"`
    TherapySessions     ImportResult `json:"therapy_sessions"`
    HomeworkItems       ImportResult `json:"homework_items"`
    PrepPacks           ImportResult `json:"prep_packs"`
    Errors              []string     `json:"errors,omitempty"`
}

type ImportResult struct {
    Total    int `json:"total"`
    Imported int `json:"imported"`
    Skipped  int `json:"skipped"`
    Failed   int `json:"failed"`
}

type DataImportModel struct {
    DB *sql.DB
}

// ImportAll validates and imports data from an ExportFile
func (m *DataImportModel) ImportAll(userID uuid.UUID, req *ImportRequest) (*ImportSummary, error) {
    // 1. Parse the export file
    var exportFile ExportFile
    if err := json.Unmarshal(req.Data, &exportFile); err != nil {
        return nil, fmt.Errorf("invalid export file: %w", err)
    }

    // 2. Validate version
    if exportFile.Version != 1 {
        return nil, fmt.Errorf("unsupported export version: %d", exportFile.Version)
    }

    // 3. Validate app
    if exportFile.App != "tranquara" {
        return nil, fmt.Errorf("invalid export file: unknown app '%s'", exportFile.App)
    }

    summary := &ImportSummary{}

    // 4. Import each data type in transaction
    // (each type wrapped in its own transaction for partial success)
    
    // Import journals
    summary.Journals = m.importJournals(userID, exportFile.Data.Journals, req.ConflictMode)
    
    // Import emotion logs
    summary.EmotionLogs = m.importEmotionLogs(userID, exportFile.Data.EmotionLogs, req.ConflictMode)
    
    // Import learned slide groups
    summary.LearnedSlideGroups = m.importLearnedSlideGroups(userID, exportFile.Data.LearnedSlideGroups, req.ConflictMode)
    
    // Import therapy sessions + dependent data
    summary.TherapySessions = m.importTherapySessions(userID, exportFile.Data.TherapySessions, req.ConflictMode)
    
    // Import homework items
    summary.HomeworkItems = m.importHomeworkItems(userID, exportFile.Data.HomeworkItems, req.ConflictMode)
    
    // Import prep packs
    summary.PrepPacks = m.importPrepPacks(userID, exportFile.Data.PrepPacks, req.ConflictMode)

    return summary, nil
}
```

**Key implementation notes:**
- Import **không** dùng original UUIDs — generate **new UUIDs** cho user mới (tránh conflict)
- `conflict_mode = "skip"`: Nếu record đã tồn tại (match bằng title+created_at hoặc content hash), bỏ qua
- `conflict_mode = "overwrite"`: Update existing record
- Mỗi data type import riêng, error 1 loại **không** ảnh hưởng các loại khác
- Journals import: validate created_at ≤ now, không cho future dates

### 3. HTTP Handlers

**File:** `cmd/api/handlers/data_portability.go`

```go
// Export handler — GET /v1/data-export
func (app *application) dataExportHandler(w http.ResponseWriter, r *http.Request) {
    userID := app.getUserIDFromContext(r)
    username := app.getUsernameFromContext(r)
    
    export, err := app.models.DataExport.ExportAll(userID, username)
    if err != nil {
        app.serverErrorResponse(w, r, err)
        return
    }
    
    // Set download headers
    filename := fmt.Sprintf("tranquara-export-%s.json", time.Now().Format("2006-01-02"))
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("Content-Disposition", fmt.Sprintf(`attachment; filename="%s"`, filename))
    
    // Encode JSON directly to response writer
    json.NewEncoder(w).Encode(export)
}

// Import handler — POST /v1/data-import
func (app *application) dataImportHandler(w http.ResponseWriter, r *http.Request) {
    userID := app.getUserIDFromContext(r)
    
    // Parse multipart form (file upload)
    file, _, err := r.FormFile("file")
    if err != nil {
        app.badRequestResponse(w, r, "no file provided")
        return
    }
    defer file.Close()
    
    conflictMode := r.FormValue("conflict_mode") // "skip" or "overwrite"
    if conflictMode == "" {
        conflictMode = "skip"
    }
    
    // Read file content
    content, err := io.ReadAll(io.LimitReader(file, 50*1024*1024)) // 50MB limit
    if err != nil {
        app.badRequestResponse(w, r, "file too large")
        return
    }
    
    req := &ImportRequest{
        ConflictMode: ImportConflictResolution(conflictMode),
        Data:         json.RawMessage(content),
    }
    
    summary, err := app.models.DataImport.ImportAll(userID, req)
    if err != nil {
        app.badRequestResponse(w, r, err.Error())
        return
    }
    
    // Return import summary
    err = app.writeJSON(w, http.StatusOK, envelope{"summary": summary}, nil)
    if err != nil {
        app.serverErrorResponse(w, r, err)
    }
}
```

### 4. Router Changes

**File:** `cmd/api/router.go` — Add two lines:

```go
// Data portability routes
router.HandlerFunc(http.MethodGet, "/v1/data-export", app.authMiddleWare(app.dataExportHandler))
router.HandlerFunc(http.MethodPost, "/v1/data-import", app.authMiddleWare(app.dataImportHandler))
```

### 5. Models Registration

**File:** `internal/data/models.go` — Add fields:

```go
type Models struct {
    // ... existing fields ...
    DataExport DataExportModel
    DataImport DataImportModel
}

func NewModels(db *sql.DB) Models {
    return Models{
        // ... existing fields ...
        DataExport: DataExportModel{DB: db},
        DataImport: DataImportModel{DB: db},
    }
}
```

---

## 🔧 Frontend Implementation (Vue/Nuxt)

### 1. Export Composable

**File:** `composables/useDataExport.ts`

```typescript
export function useDataExport() {
  const { $api } = useNuxtApp()
  const exporting = ref(false)
  const error = ref<string | null>(null)

  const exportData = async () => {
    exporting.value = true
    error.value = null

    try {
      const response = await $api('/v1/data-export', {
        method: 'GET',
        responseType: 'blob',
      })

      // Create download link
      const blob = new Blob([response], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = `tranquara-export-${new Date().toISOString().split('T')[0]}.json`
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      URL.revokeObjectURL(url)

      return true
    } catch (err: any) {
      error.value = err.message || 'Export failed'
      return false
    } finally {
      exporting.value = false
    }
  }

  return { exportData, exporting, error }
}
```

### 2. Import Composable

**File:** `composables/useDataImport.ts`

```typescript
export interface ImportSummary {
  journals: { total: number; imported: number; skipped: number; failed: number }
  emotion_logs: { total: number; imported: number; skipped: number; failed: number }
  learned_slide_groups: { total: number; imported: number; skipped: number; failed: number }
  therapy_sessions: { total: number; imported: number; skipped: number; failed: number }
  homework_items: { total: number; imported: number; skipped: number; failed: number }
  prep_packs: { total: number; imported: number; skipped: number; failed: number }
  errors?: string[]
}

export function useDataImport() {
  const { $api } = useNuxtApp()
  const importing = ref(false)
  const error = ref<string | null>(null)
  const summary = ref<ImportSummary | null>(null)

  const importData = async (file: File, conflictMode: 'skip' | 'overwrite' = 'skip') => {
    importing.value = true
    error.value = null
    summary.value = null

    try {
      // Validate file
      if (!file.name.endsWith('.json')) {
        throw new Error('Only JSON files are supported')
      }
      if (file.size > 50 * 1024 * 1024) {
        throw new Error('File too large (max 50MB)')
      }

      // Quick validation: parse and check structure
      const text = await file.text()
      const parsed = JSON.parse(text)
      if (parsed.app !== 'tranquara' || !parsed.version) {
        throw new Error('Invalid Tranquara export file')
      }

      // Upload
      const formData = new FormData()
      formData.append('file', file)
      formData.append('conflict_mode', conflictMode)

      const result = await $api('/v1/data-import', {
        method: 'POST',
        body: formData,
      })

      summary.value = result.summary
      return true
    } catch (err: any) {
      error.value = err.message || 'Import failed'
      return false
    } finally {
      importing.value = false
    }
  }

  return { importData, importing, error, summary }
}
```

### 3. Updated DataManagementSection.vue

Modify the existing `handleExportData` from "coming soon" toast to real export:

```typescript
// Replace the TODO handler:
const { exportData, exporting } = useDataExport()

const handleExportData = async () => {
  const success = await exportData()
  if (success) {
    toast.add({
      title: t('settings.dataManagement.exportSuccess'),
      description: t('settings.dataManagement.exportSuccessDesc'),
      icon: 'i-lucide-check',
      color: 'success',
    })
  }
}
```

Add Import UI section (button + file upload + results summary).

---

## 🔐 Security Considerations

1. **Authentication required** — Both endpoints use `authMiddleWare`
2. **User scoping** — All queries filtered by `user_id` from JWT token
3. **File size limit** — Import capped at 50MB
4. **Input validation** — Validate JSON structure before processing
5. **Rate limiting** — Existing rate limiter applies (avoid export spam)
6. **No sensitive tokens** — Export does NOT include auth tokens, passwords, or API keys
7. **New UUIDs on import** — Prevent UUID collision attacks

## ⚡ Performance Requirements

| Operation | Target | Notes |
|-----------|--------|-------|
| Export (< 1000 records) | < 3s | Single JSON response |
| Export (1000-10000) | < 10s | May need streaming for large datasets |
| Import (< 1000 records) | < 5s | Batch inserts |
| Import (1000-10000) | < 30s | Transaction batching |

## 🧪 Testing Strategy

### Unit Tests (Go)
- Export query returns correct data for user
- Export returns empty arrays for user with no data
- Import validates version field
- Import rejects non-tranquara files
- Import generates new UUIDs
- Import skip mode doesn't overwrite
- Import overwrite mode updates existing

### Integration Tests
- Export → Import roundtrip (data survives)
- Export with empty account
- Import with malformed JSON
- Import with wrong version number

### Manual Tests
- Download file opens correctly in text editor
- File is valid JSON
- Re-import exported file reproduces all data
- Mobile (Capacitor) download works

## 📝 Implementation Checklist

- [ ] Create `internal/data/data_export.go` — ExportAll + helper queries
- [ ] Create `internal/data/data_import.go` — ImportAll + conflict resolution
- [ ] Create `cmd/api/handlers/data_portability.go` — HTTP handlers
- [ ] Update `internal/data/models.go` — Register new models
- [ ] Update `cmd/api/router.go` — Add routes
- [ ] Create `composables/useDataExport.ts` — Frontend export
- [ ] Create `composables/useDataImport.ts` — Frontend import
- [ ] Modify `components/Settings/DataManagementSection.vue` — Wire real handlers
- [ ] Update `i18n/locales/en.json` — Add export/import i18n keys
- [ ] Update `i18n/locales/vi.json` — Add export/import i18n keys
- [ ] Test export → download → import roundtrip
- [ ] Test on mobile (Capacitor)