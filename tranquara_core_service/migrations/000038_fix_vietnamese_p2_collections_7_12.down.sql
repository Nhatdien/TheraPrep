-- Rollback: Reset slide_groups_vi to NULL for Collections 7-12
-- (They will fall back to original seed data from migrations 000029/000030)

UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = 'dddd4444-dddd-4444-dddd-dddddddd4444';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = 'eeee5555-eeee-4555-eeee-eeeeeeee5555';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = 'ffff6666-ffff-4666-ffff-ffffffff6666';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = 'a0a07777-a0a0-4777-a0a0-a0a0a0a07777';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = 'b0b08888-b0b0-4888-b0b0-b0b0b0b08888';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = '66666666-6666-4666-6666-666666666666';