-- Rollback 000036: Remove illustration field from slide_groups and slide_groups_vi
-- for the two Journey collections added in 000035.

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
BEGIN
    FOR rec IN
        SELECT id, slide_groups
        FROM journal_templates
        WHERE id IN (
            '88888888-8888-8888-8888-888888888888',
            '99999999-9999-9999-9999-999999999999'
        )
        AND slide_groups IS NOT NULL
    LOOP
        sg_arr := rec.slide_groups;
        new_sg_arr := '[]'::jsonb;

        FOR sg_idx IN 0..jsonb_array_length(sg_arr) - 1 LOOP
            sg := sg_arr->sg_idx;
            slides := sg->'slides';

            IF slides IS NULL OR jsonb_array_length(slides) = 0 THEN
                new_sg_arr := new_sg_arr || jsonb_build_array(sg);
                CONTINUE;
            END IF;

            new_slides := '[]'::jsonb;
            FOR slide_idx IN 0..jsonb_array_length(slides) - 1 LOOP
                slide := slides->slide_idx;
                slide := slide - 'illustration';
                new_slides := new_slides || jsonb_build_array(slide);
            END LOOP;

            sg := jsonb_set(sg, '{slides}', new_slides);
            new_sg_arr := new_sg_arr || jsonb_build_array(sg);
        END LOOP;

        UPDATE journal_templates SET slide_groups = new_sg_arr WHERE id = rec.id;
    END LOOP;
END $$;

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
BEGIN
    FOR rec IN
        SELECT id, slide_groups_vi
        FROM journal_templates
        WHERE id IN (
            '88888888-8888-8888-8888-888888888888',
            '99999999-9999-9999-9999-999999999999'
        )
        AND slide_groups_vi IS NOT NULL
    LOOP
        sg_arr := rec.slide_groups_vi;
        new_sg_arr := '[]'::jsonb;

        FOR sg_idx IN 0..jsonb_array_length(sg_arr) - 1 LOOP
            sg := sg_arr->sg_idx;
            slides := sg->'slides';

            IF slides IS NULL OR jsonb_array_length(slides) = 0 THEN
                new_sg_arr := new_sg_arr || jsonb_build_array(sg);
                CONTINUE;
            END IF;

            new_slides := '[]'::jsonb;
            FOR slide_idx IN 0..jsonb_array_length(slides) - 1 LOOP
                slide := slides->slide_idx;
                slide := slide - 'illustration';
                new_slides := new_slides || jsonb_build_array(slide);
            END LOOP;

            sg := jsonb_set(sg, '{slides}', new_slides);
            new_sg_arr := new_sg_arr || jsonb_build_array(sg);
        END LOOP;

        UPDATE journal_templates SET slide_groups_vi = new_sg_arr WHERE id = rec.id;
    END LOOP;
END $$;
