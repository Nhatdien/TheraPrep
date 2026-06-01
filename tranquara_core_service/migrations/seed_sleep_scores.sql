-- Seed sleep scores for journals that have a sleep_check slide (PostgreSQL)
-- Values cycle through the array in chronological order.

WITH scores (val) AS (
  VALUES
    (72),(45),(88),(60),(91),
    (38),(76),(55),(83),(67),
    (42),(79),(95),(51),(64),
    (87),(33),(70),(58),(82)
),
numbered_journals AS (
  SELECT
    uj.id,
    ROW_NUMBER() OVER (ORDER BY uj.created_at) AS rn
  FROM user_journals uj
  WHERE uj.collection_id IS NOT NULL
    AND EXISTS (
      SELECT 1
      FROM journal_templates jt,
           jsonb_array_elements(jt.slide_groups) AS sg,
           jsonb_array_elements(sg -> 'slides')  AS slide
      WHERE jt.id = uj.collection_id
        AND slide ->> 'type' = 'sleep_check'
    )
),
numbered_scores AS (
  SELECT val, ROW_NUMBER() OVER () AS rn FROM scores
)
UPDATE user_journals
SET sleep_score = ns.val,
    updated_at  = NOW()
FROM numbered_journals nj
JOIN numbered_scores   ns
  ON ((nj.rn - 1) % (SELECT COUNT(*) FROM scores)) + 1 = ns.rn
WHERE user_journals.id = nj.id;
