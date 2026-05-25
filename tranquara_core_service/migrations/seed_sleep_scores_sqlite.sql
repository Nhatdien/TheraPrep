-- Seed sleep scores for journals that have a sleep_check slide (SQLite)
-- Values cycle through the fixed list in chronological order.
-- SQLite doesn't support jsonb or arrays, so we use a VALUES table
-- and check for 'sleep_check' via LIKE on the JSON text.

WITH scores (rn, val) AS (
  VALUES
    (1,  72), (2,  45), (3,  88), (4,  60), (5,  91),
    (6,  38), (7,  76), (8,  55), (9,  83), (10, 67),
    (11, 42), (12, 79), (13, 95), (14, 51), (15, 64),
    (16, 87), (17, 33), (18, 70), (19, 58), (20, 82)
),
score_count (n) AS (
  SELECT COUNT(*) FROM scores
),
numbered_journals AS (
  SELECT
    uj.id,
    ROW_NUMBER() OVER (ORDER BY uj.created_at) AS rn
  FROM user_journals uj
  JOIN journal_templates jt ON jt.id = uj.collection_id
  WHERE uj.collection_id IS NOT NULL
    AND (
      jt.slide_groups      LIKE '%"type":"sleep_check"%'
      OR jt.slide_groups   LIKE '%"type": "sleep_check"%'
    )
)
UPDATE user_journals
SET sleep_score = (
      SELECT s.val
      FROM   scores s, score_count c
      WHERE  s.rn = ((nj.rn - 1) % c.n) + 1
    ),
    updated_at  = strftime('%Y-%m-%dT%H:%M:%SZ', 'now'),
    needs_sync  = 1
FROM numbered_journals nj
WHERE user_journals.id = nj.id;
