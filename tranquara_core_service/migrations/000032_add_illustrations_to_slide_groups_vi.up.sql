-- Migration 000032: Add illustration keywords to slide_groups_vi doc slides
-- Mirror of 000031 for the Vietnamese slide groups column.
-- 000031 only updated slide_groups; this covers slide_groups_vi.
-- Uses slide group IDs (language-agnostic) instead of title text matching
-- because slide_groups_vi titles are in Vietnamese.

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
    sg_id text;
BEGIN
    FOR rec IN
        SELECT id, slide_groups_vi
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
        AND slide_groups_vi IS NOT NULL
        AND jsonb_array_length(slide_groups_vi) > 0
    LOOP
        collection_id_str := rec.id::text;
        sg_arr := rec.slide_groups_vi;
        new_sg_arr := '[]'::jsonb;

        FOR sg_idx IN 0..jsonb_array_length(sg_arr) - 1 LOOP
            sg := sg_arr->sg_idx;
            slides := sg->'slides';
            sg_id := LOWER(COALESCE(sg->>'id', ''));

            IF slides IS NULL OR jsonb_array_length(slides) = 0 THEN
                new_sg_arr := new_sg_arr || jsonb_build_array(sg);
                CONTINUE;
            END IF;

            -- Determine illustration keyword based on collection + slide group ID
            illustration_kw := NULL;

            -- Therapy Preparation
            IF collection_id_str = '33333333-3333-3333-3333-333333333333' THEN
                illustration_kw := 'therapy';
            -- Stress Management
            ELSIF collection_id_str = '44444444-4444-4444-4444-444444444444' THEN
                illustration_kw := 'stress';
            -- Introduction to Journaling
            ELSIF collection_id_str = '22222222-2222-2222-2222-222222222222' THEN
                illustration_kw := 'journal';
            -- Understanding Anxiety
            ELSIF collection_id_str = 'bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222' THEN
                illustration_kw := 'anxiety';
            -- Better Sleep — use slide group ID for context
            ELSIF collection_id_str = 'cccc3333-cccc-4333-cccc-cccccccc3333' THEN
                IF sg_id = 'racing-thoughts' THEN
                    illustration_kw := 'breathing';
                ELSE
                    illustration_kw := 'sleep';
                END IF;
            -- Understanding Emotions — use slide group ID
            ELSIF collection_id_str = 'ffff6666-ffff-4666-ffff-ffffffff6666' THEN
                IF sg_id = 'emotional-triggers' THEN
                    illustration_kw := 'trigger';
                ELSE
                    illustration_kw := 'emotion';
                END IF;
            -- Mindfulness — use slide group ID
            ELSIF collection_id_str = 'a0a07777-a0a0-4777-a0a0-a0a0a0a07777' THEN
                IF sg_id = 'body-scan' THEN
                    illustration_kw := 'body scan';
                ELSIF sg_id = 'mindful-breathing' THEN
                    illustration_kw := 'breathing';
                ELSE
                    illustration_kw := 'mindfulness';
                END IF;
            -- Self-Compassion — use slide group ID
            ELSIF collection_id_str = 'b0b08888-b0b0-4888-b0b0-b0b0b0b08888' THEN
                IF sg_id = 'inner-critic' THEN
                    illustration_kw := 'critic';
                ELSIF sg_id = 'self-forgiveness' THEN
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

        UPDATE journal_templates SET slide_groups_vi = new_sg_arr WHERE id = rec.id;
    END LOOP;
END $$;
