-- Migration 000039: Replace "trị liệu" with "tư vấn" in Vietnamese content
-- to reduce clinical heaviness in tone.
-- Order matters: longer phrases first to avoid partial replacement.

-- ═══════════════════════════════════════════════════════
-- 1. journal_templates: title_vi column
-- ═══════════════════════════════════════════════════════

UPDATE journal_templates
SET title_vi = REPLACE(title_vi, 'Chuẩn bị trị liệu', 'Chuẩn bị tư vấn')
WHERE title_vi LIKE '%Chuẩn bị trị liệu%';

-- ═══════════════════════════════════════════════════════
-- 2. journal_templates: description_vi column
-- ═══════════════════════════════════════════════════════

-- Replace "nhà trị liệu" → "chuyên gia tư vấn" first
UPDATE journal_templates
SET description_vi = REPLACE(description_vi, 'nhà trị liệu', 'chuyên gia tư vấn')
WHERE description_vi LIKE '%nhà trị liệu%';

-- Then remaining "trị liệu" → "tư vấn"
UPDATE journal_templates
SET description_vi = REPLACE(description_vi, 'trị liệu', 'tư vấn')
WHERE description_vi LIKE '%trị liệu%';

-- ═══════════════════════════════════════════════════════
-- 3. journal_templates: slide_groups_vi JSONB column
-- ═══════════════════════════════════════════════════════

-- Replace "nhà trị liệu" → "chuyên gia tư vấn" first (in JSONB text)
UPDATE journal_templates
SET slide_groups_vi = REPLACE(slide_groups_vi::text, 'nhà trị liệu', 'chuyên gia tư vấn')::jsonb
WHERE slide_groups_vi::text LIKE '%nhà trị liệu%';

-- Then remaining "trị liệu" → "tư vấn"
UPDATE journal_templates
SET slide_groups_vi = REPLACE(slide_groups_vi::text, 'trị liệu', 'tư vấn')::jsonb
WHERE slide_groups_vi::text LIKE '%trị liệu%';

-- ═══════════════════════════════════════════════════════
-- 4. Also update slide_groups (English/fallback JSONB) if it contains Vietnamese
-- ═══════════════════════════════════════════════════════

-- Replace "nhà trị liệu" first
UPDATE journal_templates
SET slide_groups = REPLACE(slide_groups::text, 'nhà trị liệu', 'chuyên gia tư vấn')::jsonb
WHERE slide_groups::text LIKE '%nhà trị liệu%';

-- Then remaining "trị liệu"
UPDATE journal_templates
SET slide_groups = REPLACE(slide_groups::text, 'trị liệu', 'tư vấn')::jsonb
WHERE slide_groups::text LIKE '%trị liệu%';