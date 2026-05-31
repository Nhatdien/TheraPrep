-- Media Upload Feature: media_files + journal_entry_media
-- Stores uploaded image metadata and links media to journal entries

-- media_files: metadata for all uploaded files
CREATE TABLE IF NOT EXISTS media_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    filename TEXT NOT NULL,
    content_type TEXT NOT NULL,
    size_bytes BIGINT NOT NULL,
    r2_key TEXT NOT NULL UNIQUE,
    r2_url TEXT NOT NULL,
    upload_status TEXT NOT NULL DEFAULT 'pending' CHECK (upload_status IN ('pending', 'confirmed', 'failed')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_media_files_user_id ON media_files(user_id);
CREATE INDEX idx_media_files_upload_status ON media_files(upload_status);
CREATE INDEX idx_media_files_r2_key ON media_files(r2_key);

-- journal_entry_media: links media files to journal entry slides
CREATE TABLE IF NOT EXISTS journal_entry_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_entry_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
    media_file_id UUID NOT NULL REFERENCES media_files(id) ON DELETE CASCADE,
    slide_index INTEGER NOT NULL DEFAULT 0,
    position INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (journal_entry_id, slide_index, position)
);

CREATE INDEX idx_jem_journal_entry_id ON journal_entry_media(journal_entry_id);
CREATE INDEX idx_jem_media_file_id ON journal_entry_media(media_file_id);