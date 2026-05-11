-- Add sleep_score column to user_journals
-- Stores the sleep quality score (0–100) from sleep_check slides
ALTER TABLE user_journals ADD COLUMN sleep_score INTEGER CHECK (sleep_score >= 0 AND sleep_score <= 100);
