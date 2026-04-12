-- Migration 000031: Add illustration keywords to educational doc slides
-- Adds "illustration" field to the first doc-type slide in each slide group
-- for learn-type collections, enabling per-slide contextual illustrations.
--
-- Strategy: Use a PL/pgSQL function to iterate through slide_groups JSONB,
-- find the first "doc" slide in each slide group, and add the illustration keyword.

DO $$
DECLARE
    rec RECORD;
    sg_arr jsonb;
    sg jsonb;
    slides jsonb;
    slide jsonb;
    new_slides jsonb;
    new_sg_arr jsonb;
    sg_idx int;
    slide_idx int;
    first_doc_found boolean;
    illustration_kw text;
    collection_id_str text;
    sg_title text;
BEGIN
    -- Process each collection that has educational doc slides
    FOR rec IN
        SELECT id, slide_groups, title
        FROM journal_templates
        WHERE id IN (
            '33333333-3333-3333-3333-333333333333', -- Therapy Preparation
            '44444444-4444-4444-4444-444444444444', -- Stress Management
            '22222222-2222-2222-2222-222222222222', -- Introduction to Journaling
            'bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222', -- Understanding Anxiety
            'cccc3333-cccc-4333-cccc-cccccccc3333', -- Better Sleep
            'ffff6666-ffff-4666-ffff-ffffffff6666', -- Understanding Emotions
            'a0a07777-a0a0-4777-a0a0-a0a0a0a07777', -- Mindfulness
            'b0b08888-b0b0-4888-b0b0-b0b0b0b08888'  -- Self-Compassion
        )
        AND slide_groups IS NOT NULL
    LOOP
        collection_id_str := rec.id::text;
        sg_arr := rec.slide_groups;
        new_sg_arr := '[]'::jsonb;

        FOR sg_idx IN 0..jsonb_array_length(sg_arr) - 1 LOOP
            sg := sg_arr->sg_idx;
            slides := sg->'slides';
            sg_title := LOWER(COALESCE(sg->>'title', ''));

            IF slides IS NULL OR jsonb_array_length(slides) = 0 THEN
                new_sg_arr := new_sg_arr || jsonb_build_array(sg);
                CONTINUE;
            END IF;

            -- Determine illustration keyword based on collection + slide group context
            illustration_kw := NULL;

            -- Therapy Preparation
            IF collection_id_str = '33333333-3333-3333-3333-333333333333' THEN
                illustration_kw := 'therapy';
            -- Stress Management
            ELSIF collection_id_str = '44444444-4444-4444-4444-444444444444' THEN
                illustration_kw := 'stress';
            -- Introduction to Journaling
            ELSIF collection_id_str = '22222222-2222-2222-2222-222222222222' THEN
                IF sg_title LIKE '%first session%' OR sg_title LIKE '%therapy%' THEN
                    illustration_kw := 'therapy';
                ELSE
                    illustration_kw := 'journal';
                END IF;
            -- Understanding Anxiety
            ELSIF collection_id_str = 'bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222' THEN
                illustration_kw := 'anxiety';
            -- Better Sleep
            ELSIF collection_id_str = 'cccc3333-cccc-4333-cccc-cccccccc3333' THEN
                IF sg_title LIKE '%racing%' OR sg_title LIKE '%soothing%' THEN
                    illustration_kw := 'breathing';
                ELSE
                    illustration_kw := 'sleep';
                END IF;
            -- Understanding Emotions
            ELSIF collection_id_str = 'ffff6666-ffff-4666-ffff-ffffffff6666' THEN
                IF sg_title LIKE '%trigger%' THEN
                    illustration_kw := 'trigger';
                ELSE
                    illustration_kw := 'emotion';
                END IF;
            -- Mindfulness
            ELSIF collection_id_str = 'a0a07777-a0a0-4777-a0a0-a0a0a0a07777' THEN
                IF sg_title LIKE '%body scan%' OR sg_title LIKE '%body%' THEN
                    illustration_kw := 'body scan';
                ELSIF sg_title LIKE '%breath%' THEN
                    illustration_kw := 'breathing';
                ELSE
                    illustration_kw := 'mindfulness';
                END IF;
            -- Self-Compassion
            ELSIF collection_id_str = 'b0b08888-b0b0-4888-b0b0-b0b0b0b08888' THEN
                IF sg_title LIKE '%critic%' THEN
                    illustration_kw := 'critic';
                ELSIF sg_title LIKE '%forgiv%' THEN
                    illustration_kw := 'forgive';
                ELSE
                    illustration_kw := 'compassion';
                END IF;
            END IF;

            -- Add illustration to first doc slide only
            new_slides := '[]'::jsonb;
            first_doc_found := FALSE;

            FOR slide_idx IN 0..jsonb_array_length(slides) - 1 LOOP
                slide := slides->slide_idx;

                IF NOT first_doc_found
                   AND slide->>'type' = 'doc'
                   AND illustration_kw IS NOT NULL
                   AND slide->>'illustration' IS NULL
                THEN
                    slide := slide || jsonb_build_object('illustration', illustration_kw);
                    first_doc_found := TRUE;
                END IF;

                new_slides := new_slides || jsonb_build_array(slide);
            END LOOP;

            sg := jsonb_set(sg, '{slides}', new_slides);
            new_sg_arr := new_sg_arr || jsonb_build_array(sg);
        END LOOP;

        UPDATE journal_templates SET slide_groups = new_sg_arr WHERE id = rec.id;
    END LOOP;
END $$;
