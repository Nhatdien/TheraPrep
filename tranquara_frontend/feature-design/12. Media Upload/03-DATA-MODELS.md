# Media Upload - Data Models

## 📊 Database Tables

### Table: `media_files`

**Purpose**: Stores metadata for all uploaded media files

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Primary key |
| `user_id` | UUID | FK → users(id), NOT NULL | Owner of the file |
| `filename` | TEXT | NOT NULL | Original filename |
| `content_type` | TEXT | NOT NULL | MIME type (image/jpeg, image/png, image/webp) |
| `size_bytes` | BIGINT | NOT NULL | File size in bytes |
| `r2_key` | TEXT | NOT NULL, UNIQUE | Path in R2 bucket |
| `r2_url` | TEXT | NOT NULL | Full URL to access file |
| `upload_status` | TEXT | NOT NULL, DEFAULT 'pending' | pending / confirmed / failed |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Upload timestamp |

**Indexes:**
- `idx_media_files_user_id` on `user_id`
- `idx_media_files_upload_status` on `upload_status`
- `idx_media_files_r2_key` on `r2_key`

### Table: `journal_entry_media`

**Purpose**: Junction table linking media files to specific journal entry slides

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Primary key |
| `journal_entry_id` | UUID | FK → journal_entries(id), NOT NULL | Journal entry reference |
| `media_file_id` | UUID | FK → media_files(id), NOT NULL | Media file reference |
| `slide_index` | INTEGER | NOT NULL DEFAULT 0 | Which slide in the journal |
| `position` | INTEGER | NOT NULL DEFAULT 0 | Order within the slide |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Attachment timestamp |

**Indexes:**
- `idx_jem_journal_entry_id` on `journal_entry_id`
- `idx_jem_media_file_id` on `media_file_id`
- `uq_jem_entry_slide_position` UNIQUE on `(journal_entry_id, slide_index, position)`

**Relationships:**
- Belongs to `journal_entries` via `journal_entry_id`
- Belongs to `media_files` via `media_file_id`
- Cascade delete: deleting journal entry removes junction rows; deleting media file removes junction rows

## 🔄 Data Flow

```
1. User selects image
   ↓
2. Frontend validates (type, size, count)
   ↓
3. Frontend → POST /api/v1/media/presign
   ↓
4. Backend creates media_files row (status: pending) + generates presigned URL
   ↓
5. Backend returns { media_id, upload_url, download_url }
   ↓
6. Frontend → PUT file directly to R2 via presigned URL
   ↓
7. Frontend → POST /api/v1/media/{id}/confirm
   ↓
8. Backend updates media_files row (status: confirmed)
   ↓
9. On journal save: Frontend sends media_ids per slide
   ↓
10. Backend upserts journal_entry_media rows
```

## 📝 Sample Data

### media_files record
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "filename": "sunset_mood.jpg",
  "content_type": "image/jpeg",
  "size_bytes": 1843200,
  "r2_key": "media/users/123e4567-e89b-12d3-a456-426614174000/a1b2c3d4_sunset_mood.jpg",
  "r2_url": "https://cdn.tranquara.com/media/users/123e4567-e89b-12d3-a456-426614174000/a1b2c3d4_sunset_mood.jpg",
  "upload_status": "confirmed",
  "created_at": "2026-05-31T18:30:00Z"
}
```

### journal_entry_media record
```json
{
  "id": "f0e1d2c3-b4a5-6789-0123-456789abcdef",
  "journal_entry_id": "987e6543-e21b-43d2-b456-426614174000",
  "media_file_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "slide_index": 2,
  "position": 0,
  "created_at": "2026-05-31T18:35:00Z"
}
```

## 🚀 Migration Notes

- Migration number: 000040
- No breaking changes to existing tables
- `journal_entry_media` uses ON DELETE CASCADE for both FKs
- `upload_status` uses TEXT instead of ENUM for simplicity
- Down migration drops both tables