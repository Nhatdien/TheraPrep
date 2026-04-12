-- Revert migration 000029: Clear slide_groups_vi for all collections
-- The original 000026 migration only set title_vi and description_vi, not slide_groups_vi

UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = '55555555-5555-5555-5555-555555555555';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = '33333333-3333-3333-3333-333333333333';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = '44444444-4444-4444-4444-444444444444';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = '22222222-2222-2222-2222-222222222222';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = 'bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = 'cccc3333-cccc-4333-cccc-cccccccc3333';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = 'dddd4444-dddd-4444-dddd-dddddddd4444';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = 'eeee5555-eeee-4555-eeee-eeeeeeee5555';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = 'ffff6666-ffff-4666-ffff-ffffffff6666';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = 'a0a07777-a0a0-4777-a0a0-a0a0a0a07777';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = 'b0b08888-b0b0-4888-b0b0-b0b0b0b08888';
UPDATE journal_templates SET slide_groups_vi = NULL WHERE id = '66666666-6666-4666-6666-666666666666';
