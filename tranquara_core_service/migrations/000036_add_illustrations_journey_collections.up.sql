-- Migration 000036: Add illustration keywords to slide_groups and slide_groups_vi
-- for the two new Journey collections added in 000035.
-- Mirrors the pattern from migrations 000031 (English) and 000032 (Vietnamese).
--
-- Collections:
--   88888888 — Your Mental Health History  → illustration: 'therapy'
--   99999999 — Your Lifestyle & Support
--     sleep-routines group               → illustration: 'lifestyle'
--     support-network group              → illustration: 'support'

-- ─── English slide_groups ────────────────────────────────────────────────────
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
        SELECT id, slide_groups
        FROM journal_templates
        WHERE id IN (
            '88888888-8888-8888-8888-888888888888', -- Your Mental Health History
            '99999999-9999-9999-9999-999999999999'  -- Your Lifestyle & Support
        )
        AND slide_groups IS NOT NULL
    LOOP
        collection_id_str := rec.id::text;
        sg_arr := rec.slide_groups;
        new_sg_arr := '[]'::jsonb;

        FOR sg_idx IN 0..jsonb_array_length(sg_arr) - 1 LOOP
            sg := sg_arr->sg_idx;
            slides := sg->'slides';
            sg_id := LOWER(COALESCE(sg->>'id', ''));

            IF slides IS NULL OR jsonb_array_length(slides) = 0 THEN
                new_sg_arr := new_sg_arr || jsonb_build_array(sg);
                CONTINUE;
            END IF;

            -- Determine illustration keyword
            illustration_kw := NULL;

            IF collection_id_str = '88888888-8888-8888-8888-888888888888' THEN
                illustration_kw := 'therapy';
            ELSIF collection_id_str = '99999999-9999-9999-9999-999999999999' THEN
                IF sg_id = 'sleep-routines' THEN
                    illustration_kw := 'lifestyle';
                ELSIF sg_id = 'support-network' THEN
                    illustration_kw := 'support';
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

-- ─── Vietnamese slide_groups_vi ──────────────────────────────────────────────
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
            '88888888-8888-8888-8888-888888888888',
            '99999999-9999-9999-9999-999999999999'
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

            illustration_kw := NULL;

            IF collection_id_str = '88888888-8888-8888-8888-888888888888' THEN
                illustration_kw := 'therapy';
            ELSIF collection_id_str = '99999999-9999-9999-9999-999999999999' THEN
                IF sg_id = 'sleep-routines' THEN
                    illustration_kw := 'lifestyle';
                ELSIF sg_id = 'support-network' THEN
                    illustration_kw := 'support';
                END IF;
            END IF;

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
