-- Rollback 000035: Remove seeded Journey collections (Step 2 & Step 3)
DELETE FROM journal_templates
WHERE id IN (
    '88888888-8888-8888-8888-888888888888'::uuid,
    '99999999-9999-9999-9999-999999999999'::uuid
);
