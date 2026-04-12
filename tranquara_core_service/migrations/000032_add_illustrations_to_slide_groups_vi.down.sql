-- Rollback: Remove illustration field from all slides in slide_groups_vi

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
            '33333333-3333-3333-3333-333333333333',
            '44444444-4444-4444-4444-444444444444',
            '22222222-2222-2222-2222-222222222222',
            'bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222',
            'cccc3333-cccc-4333-cccc-cccccccc3333',
            'ffff6666-ffff-4666-ffff-ffffffff6666',
            'a0a07777-a0a0-4777-a0a0-a0a0a0a07777',
            'b0b08888-b0b0-4888-b0b0-b0b0b0b08888'
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
