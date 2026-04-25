CREATE TABLE IF NOT EXISTS user_custom_templates (
    id         UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title      VARCHAR(255) NOT NULL DEFAULT 'My Daily Template',
    slide_groups JSONB     NOT NULL DEFAULT '[]',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id),
    UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_custom_templates_user_id ON user_custom_templates(user_id);
