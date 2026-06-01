-- Rollback: Revert "tư vấn" back to "trị liệu" in Vietnamese content
-- Order matters: revert "tư vấn" → "trị liệu" first, then "chuyên gia tư vấn" → "nhà trị liệu"

-- ═══════════════════════════════════════════════════════
-- 1. journal_templates: title_vi column
-- ═══════════════════════════════════════════════════════

UPDATE journal_templates
SET title_vi = REPLACE(title_vi, 'Chuẩn bị tư vấn', 'Chuẩn bị trị liệu')
WHERE title_vi LIKE '%Chuẩn bị tư vấn%';

-- ═══════════════════════════════════════════════════════
-- 2. journal_templates: description_vi column
-- ═══════════════════════════════════════════════════════

-- Revert "tư vấn" → "trị liệu" first
UPDATE journal_templates
SET description_vi = REPLACE(description_vi, 'tư vấn', 'trị liệu')
WHERE description_vi LIKE '%tư vấn%';

-- Then revert "chuyên gia trị liệu" → "nhà trị liệu"
UPDATE journal_templates
SET description_vi = REPLACE(description_vi, 'chuyên gia trị liệu', 'nhà trị liệu')
WHERE description_vi LIKE '%chuyên gia trị liệu%';

-- ═══════════════════════════════════════════════════════
-- 3. journal_templates: slide_groups_vi JSONB column
-- ═══════════════════════════════════════════════════════

-- Revert "tư vấn" → "trị liệu"
UPDATE journal_templates
SET slide_groups_vi = REPLACE(slide_groups_vi::text, 'tư vấn', 'trị liệu')::jsonb
WHERE slide_groups_vi::text LIKE '%tư vấn%';

-- Then revert "chuyên gia trị liệu" → "nhà trị liệu"
UPDATE journal_templates
SET slide_groups_vi = REPLACE(slide_groups_vi::text, 'chuyên gia trị liệu', 'nhà trị liệu')::jsonb
WHERE slide_groups_vi::text LIKE '%chuyên gia trị liệu%';

-- ═══════════════════════════════════════════════════════
-- 4. slide_groups JSONB column
-- ═══════════════════════════════════════════════════════

UPDATE journal_templates
SET slide_groups = REPLACE(slide_groups::text, 'tư vấn', 'trị liệu')::jsonb
WHERE slide_groups::text LIKE '%tư vấn%';

UPDATE journal_templates
SET slide_groups = REPLACE(slide_groups::text, 'chuyên gia trị liệu', 'nhà trị liệu')::jsonb
WHERE slide_groups::text LIKE '%chuyên gia trị liệu%';