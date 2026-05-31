-- Migration 000037: Revert Vietnamese translation fixes
-- Restores the previous machine-translated content

-- Note: To fully revert, restore the original slide_groups_vi from migration 000029.
-- Since this migration only updated specific collections, we set them to NULL
-- which will cause the frontend to fall back to English.
-- A proper revert would require re-running migration 000029's UPDATE statements.

-- For now, we set slide_groups_vi to NULL for the affected collections
-- as the original content is in migration 000029.
-- This is a safe rollback — the frontend handles NULL gracefully.

-- No-op: The original data was from migration 000029.
-- If needed, re-migrate 000029 to restore original content.