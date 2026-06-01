-- Migration 000035: Seed missing Journey collections
-- Inserts Step 2 (88888888) — "Your Mental Health History"
-- Inserts Step 3 (99999999) — "Your Lifestyle & Support"
-- Both are type='learn' with two slide_groups each.

-- ============================================================================
-- Collection: Your Mental Health History (88888888-8888-8888-8888-888888888888)
-- Journey Step 2 — type='learn', category='mental_health'
-- Slide Group 1: Past Diagnoses & Treatments
-- Slide Group 2: Medications & Crisis History
-- ============================================================================
INSERT INTO journal_templates (id, title, description, category, type, slide_groups, is_active) VALUES (
    '88888888-8888-8888-8888-888888888888'::uuid,
    'Your Mental Health History',
    'Reflect on past diagnoses, treatment experiences, medications, and crisis history to share with your therapist.',
    'mental_health',
    'learn',
    $$[
        {
            "id": "past-diagnoses",
            "title": "Past Diagnoses & Treatments",
            "description": "Reflect on any past diagnoses and what has or has not helped you.",
            "position": 1,
            "slides": [
                {
                    "id": "history-why-matters",
                    "type": "doc",
                    "title": "Why your history matters",
                    "content": "<h3>Why your history matters</h3><p>Your mental health history helps a therapist understand the full picture — not just where you are now, but what you have been through. Sharing this context makes your sessions more focused and effective.</p><p>There is no need to remember everything perfectly. Share what feels relevant and comfortable.</p>",
                    "illustration": "therapy"
                },
                {
                    "id": "history-diagnoses-check",
                    "type": "questionnaire",
                    "question": "Have you ever been diagnosed with any of the following?",
                    "content": "Select all that apply. This is just for your reflection — you can edit what you share with your therapist.",
                    "mode": "multi",
                    "options": [
                        {"id": "anxiety", "label": "Anxiety disorder", "description": "Generalised anxiety, social anxiety, panic disorder, etc."},
                        {"id": "depression", "label": "Depression", "description": "Major depressive disorder, persistent depressive disorder, etc."},
                        {"id": "ptsd", "label": "PTSD / Trauma", "description": "Post-traumatic stress disorder, complex PTSD"},
                        {"id": "adhd", "label": "ADHD", "description": "Attention-deficit/hyperactivity disorder"},
                        {"id": "bipolar", "label": "Bipolar disorder"},
                        {"id": "ocd", "label": "OCD", "description": "Obsessive-compulsive disorder"},
                        {"id": "eating", "label": "Eating disorder", "description": "Anorexia, bulimia, binge-eating disorder, etc."},
                        {"id": "other", "label": "Another condition not listed"},
                        {"id": "none", "label": "No formal diagnosis"},
                        {"id": "unsure", "label": "I am not sure"},
                        {"id": "prefer-not", "label": "Prefer not to say"}
                    ]
                },
                {
                    "id": "history-treatment-past",
                    "type": "journal_prompt",
                    "question": "What mental health treatment or support have you received in the past?",
                    "config": {
                        "allowAI": true,
                        "minLength": 20
                    }
                },
                {
                    "id": "history-what-helped",
                    "type": "journal_prompt",
                    "question": "What helped you, and what did not? What do you wish had been different?",
                    "config": {
                        "allowAI": true
                    }
                },
                {
                    "id": "past-diagnoses-completion",
                    "type": "completion",
                    "title": "Reflection complete",
                    "content": "Looking back at your history takes courage. This reflection will help you have a much more productive first session.",
                    "metric_label": "Past diagnoses & treatments reviewed",
                    "recommended_next": [
                        {
                            "slide_group_id": "medications-crisis",
                            "collection_id": "88888888-8888-8888-8888-888888888888",
                            "title": "Medications & Crisis History",
                            "description": "Reflect on medications and any past mental health crises."
                        }
                    ]
                }
            ]
        },
        {
            "id": "medications-crisis",
            "title": "Medications & Crisis History",
            "description": "Help your therapist understand your medication history and any past mental health crises.",
            "position": 2,
            "slides": [
                {
                    "id": "meds-why-share",
                    "type": "doc",
                    "title": "Why share medication information",
                    "content": "<h3>Why share medication information</h3><p>Medications — both current and past — affect how your brain and body feel. Sharing this with your therapist helps them understand your baseline, avoid conflicting recommendations, and coordinate with any prescribing doctors if needed.</p><p>If you would rather not share, that is okay — this is your space to reflect first.</p>",
                    "illustration": "therapy"
                },
                {
                    "id": "meds-list",
                    "type": "checklist_input",
                    "question": "List any mental health medications you are currently taking or have taken in the past.",
                    "config": {
                        "placeholder": "e.g. Sertraline 50mg (2022-2023)..."
                    }
                },
                {
                    "id": "crisis-gentle-note",
                    "type": "doc",
                    "title": "A note before the next question",
                    "content": "<h3>A note before the next question</h3><p>The next prompt asks about mental health crises — moments where you may have felt unable to cope, harmed yourself, or needed urgent help.</p><p>This is entirely optional. Answer only what you feel comfortable sharing with yourself right now. There are no right or wrong answers here.</p>"
                },
                {
                    "id": "crisis-history",
                    "type": "journal_prompt",
                    "question": "If you have experienced a mental health crisis — describe what happened and how you got through it. (Optional — skip if you prefer.)",
                    "config": {
                        "allowAI": true
                    }
                },
                {
                    "id": "history-key-things",
                    "type": "journal_prompt",
                    "question": "What is the most important thing you want your therapist to know about your mental health history?",
                    "config": {
                        "allowAI": true,
                        "minLength": 20
                    }
                },
                {
                    "id": "medications-crisis-completion",
                    "type": "completion",
                    "title": "Step 2 complete",
                    "content": "You have reflected on your mental health history. This is one of the most valuable things you can bring into therapy.",
                    "metric_label": "Medications & crisis history reviewed",
                    "recommended_next": [
                        {
                            "slide_group_id": "sleep-routines",
                            "collection_id": "99999999-9999-9999-9999-999999999999",
                            "title": "Sleep & Daily Routines",
                            "description": "Explore how your daily rhythms affect your mental health."
                        }
                    ]
                }
            ]
        }
    ]$$::jsonb,
    true
);

-- ============================================================================
-- Collection: Your Lifestyle & Support (99999999-9999-9999-9999-999999999999)
-- Journey Step 3 — type='learn', category='mental_health'
-- Slide Group 1: Sleep & Daily Routines
-- Slide Group 2: Your Support Network
-- ============================================================================
INSERT INTO journal_templates (id, title, description, category, type, slide_groups, is_active) VALUES (
    '99999999-9999-9999-9999-999999999999'::uuid,
    'Your Lifestyle & Support',
    'Explore how sleep, daily routines, diet, and your support network shape your mental wellbeing.',
    'mental_health',
    'learn',
    $$[
        {
            "id": "sleep-routines",
            "title": "Sleep & Daily Routines",
            "description": "Understand how your daily rhythms and habits affect your mental health.",
            "position": 1,
            "slides": [
                {
                    "id": "lifestyle-rhythms-matter",
                    "type": "doc",
                    "title": "Your daily rhythms matter",
                    "content": "<h3>Your daily rhythms matter</h3><p>Sleep, nutrition, exercise, and routine are not just physical health topics — they are deeply connected to mood, energy, and emotional regulation.</p><p>Therapists often ask about lifestyle because small changes here can have a big impact on how you feel mentally.</p>",
                    "illustration": "lifestyle"
                },
                {
                    "id": "lifestyle-sleep-check",
                    "type": "sleep_check",
                    "question": "How would you rate your sleep quality over the past week?",
                    "config": {
                        "min": 0,
                        "max": 100
                    }
                },
                {
                    "id": "lifestyle-struggles-check",
                    "type": "questionnaire",
                    "question": "Which lifestyle areas do you feel are affecting your mental health?",
                    "content": "Select all that apply.",
                    "mode": "multi",
                    "options": [
                        {"id": "sleep", "label": "Sleep", "description": "Trouble falling asleep, staying asleep, or oversleeping"},
                        {"id": "exercise", "label": "Physical activity", "description": "Too little or too much exercise"},
                        {"id": "diet", "label": "Diet & nutrition", "description": "Irregular eating, comfort eating, or restriction"},
                        {"id": "screens", "label": "Screen time & social media", "description": "Doom-scrolling, comparison, digital overwhelm"},
                        {"id": "substances", "label": "Alcohol or substances", "description": "Using substances to cope with stress or emotions"},
                        {"id": "work-life", "label": "Work-life balance", "description": "Overworking, burnout, not enough downtime"},
                        {"id": "routine", "label": "Lack of routine", "description": "Unstructured days or inconsistent schedule"},
                        {"id": "none", "label": "None of these right now"}
                    ]
                },
                {
                    "id": "lifestyle-typical-day",
                    "type": "journal_prompt",
                    "question": "Describe your typical day from morning to night. What does it look like right now?",
                    "config": {
                        "allowAI": true,
                        "minLength": 30
                    }
                },
                {
                    "id": "lifestyle-helpful-habits",
                    "type": "journal_prompt",
                    "question": "What habits or routines help support your mental health? What would you like to change?",
                    "config": {
                        "allowAI": true
                    }
                },
                {
                    "id": "sleep-routines-completion",
                    "type": "completion",
                    "title": "Great self-awareness",
                    "content": "Understanding how your daily habits connect to your mood is a powerful insight to bring into therapy.",
                    "metric_label": "Sleep & routines reflection complete",
                    "recommended_next": [
                        {
                            "slide_group_id": "support-network",
                            "collection_id": "99999999-9999-9999-9999-999999999999",
                            "title": "Your Support Network",
                            "description": "Reflect on the people and connections that sustain you."
                        }
                    ]
                }
            ]
        },
        {
            "id": "support-network",
            "title": "Your Support Network",
            "description": "Reflect on the people around you and what you need from your support system.",
            "position": 2,
            "slides": [
                {
                    "id": "support-why-matters",
                    "type": "doc",
                    "title": "Social support and mental health",
                    "content": "<h3>Social support and mental health</h3><p>Research consistently shows that <strong>having even one trusted person</strong> to talk to significantly reduces the impact of stress and mental health difficulties.</p><p>Your therapist will want to understand who is in your corner — and where there might be gaps or challenges in your relationships.</p>",
                    "illustration": "support"
                },
                {
                    "id": "support-who-check",
                    "type": "questionnaire",
                    "question": "Who do you have in your support network right now?",
                    "content": "Select all that apply.",
                    "mode": "multi",
                    "options": [
                        {"id": "family", "label": "Family", "description": "Parents, siblings, relatives"},
                        {"id": "friends", "label": "Close friends"},
                        {"id": "partner", "label": "Partner or significant other"},
                        {"id": "therapist", "label": "Current therapist or counselor"},
                        {"id": "online", "label": "Online community or peer support"},
                        {"id": "religious", "label": "Religious or spiritual community"},
                        {"id": "colleagues", "label": "Work colleagues or mentor"},
                        {"id": "pets", "label": "Pets"},
                        {"id": "none", "label": "I feel I have no support right now"}
                    ]
                },
                {
                    "id": "support-helpful",
                    "type": "journal_prompt",
                    "question": "Who in your life understands what you are going through, or tries to? How do they support you?",
                    "config": {
                        "allowAI": true,
                        "minLength": 20
                    }
                },
                {
                    "id": "support-challenges",
                    "type": "journal_prompt",
                    "question": "Is there anyone in your life who makes things harder for you? You do not have to name them — just describe the dynamic if you feel comfortable.",
                    "config": {
                        "allowAI": true
                    }
                },
                {
                    "id": "support-needs",
                    "type": "journal_prompt",
                    "question": "What does support mean to you? What do you need from the people around you?",
                    "config": {
                        "allowAI": true
                    }
                },
                {
                    "id": "support-network-completion",
                    "type": "completion",
                    "title": "Step 3 complete",
                    "content": "Understanding your support system helps your therapist see your world more clearly. You are almost ready for your session.",
                    "metric_label": "Support network reflection complete",
                    "recommended_next": [
                        {
                            "slide_group_id": "stress-check-in",
                            "collection_id": "44444444-4444-4444-4444-444444444444",
                            "title": "Prepare for Your Session",
                            "description": "The final step — get ready to walk into therapy feeling prepared."
                        }
                    ]
                }
            ]
        }
    ]$$::jsonb,
    true
);

-- ============================================================================
-- Vietnamese translations: title_vi, description_vi
-- ============================================================================
UPDATE journal_templates SET
    title_vi = 'Lịch sử sức khỏe tâm thần',
    description_vi = 'Suy ngẫm về các chẩn đoán, trải nghiệm điều trị, thuốc và lịch sử khủng hoảng để chia sẻ với nhà trị liệu.'
WHERE id = '88888888-8888-8888-8888-888888888888';

UPDATE journal_templates SET
    title_vi = 'Lối sống & Hỗ trợ',
    description_vi = 'Khám phá cách giấc ngủ, thói quen hàng ngày, chế độ ăn và mạng lưới hỗ trợ ảnh hưởng đến sức khỏe tinh thần.'
WHERE id = '99999999-9999-9999-9999-999999999999';

-- ============================================================================
-- Vietnamese slide groups
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "past-diagnoses",
        "title": "Chẩn đoán & Điều trị trong quá khứ",
        "description": "Suy ngẫm về các chẩn đoán trong quá khứ và những gì đã hoặc chưa giúp ích cho bạn.",
        "position": 1,
        "slides": [
            {
                "id": "history-why-matters",
                "type": "doc",
                "title": "Tại sao lịch sử của bạn quan trọng",
                "content": "<h3>Tại sao lịch sử của bạn quan trọng</h3><p>Lịch sử sức khỏe tâm thần giúp nhà trị liệu hiểu toàn cảnh — không chỉ nơi bạn đang ở hiện tại, mà còn những gì bạn đã trải qua. Chia sẻ bối cảnh này giúp các buổi trị liệu tập trung và hiệu quả hơn.</p><p>Bạn không cần nhớ mọi thứ một cách hoàn hảo. Hãy chia sẻ những gì cảm thấy phù hợp và thoải mái.</p>",
                "illustration": "therapy"
            },
            {
                "id": "history-diagnoses-check",
                "type": "questionnaire",
                "question": "Bạn đã từng được chẩn đoán mắc bất kỳ tình trạng nào sau đây chưa?",
                "content": "Chọn tất cả những gì phù hợp. Đây chỉ để bạn suy ngẫm — bạn có thể chỉnh sửa những gì muốn chia sẻ với nhà trị liệu.",
                "mode": "multi",
                "options": [
                    {"id": "anxiety", "label": "Rối loạn lo âu", "description": "Lo âu lan tỏa, lo âu xã hội, rối loạn hoảng sợ, v.v."},
                    {"id": "depression", "label": "Trầm cảm", "description": "Rối loạn trầm cảm nặng, trầm cảm dai dẳng, v.v."},
                    {"id": "ptsd", "label": "PTSD / Chấn thương tâm lý"},
                    {"id": "adhd", "label": "ADHD", "description": "Rối loạn tăng động giảm chú ý"},
                    {"id": "bipolar", "label": "Rối loạn lưỡng cực"},
                    {"id": "ocd", "label": "OCD", "description": "Rối loạn ám ảnh cưỡng chế"},
                    {"id": "eating", "label": "Rối loạn ăn uống"},
                    {"id": "other", "label": "Tình trạng khác không có trong danh sách"},
                    {"id": "none", "label": "Chưa được chẩn đoán chính thức"},
                    {"id": "unsure", "label": "Tôi không chắc"},
                    {"id": "prefer-not", "label": "Không muốn chia sẻ"}
                ]
            },
            {
                "id": "history-treatment-past",
                "type": "journal_prompt",
                "question": "Bạn đã từng nhận được hỗ trợ hay điều trị sức khỏe tâm thần nào trong quá khứ?",
                "config": { "allowAI": true, "minLength": 20 }
            },
            {
                "id": "history-what-helped",
                "type": "journal_prompt",
                "question": "Điều gì đã giúp ích, và điều gì không? Bạn ước gì có thể thay đổi điều gì?",
                "config": { "allowAI": true }
            },
            {
                "id": "past-diagnoses-completion",
                "type": "completion",
                "title": "Đã hoàn tất việc suy ngẫm",
                "content": "Nhìn lại lịch sử của bạn đòi hỏi sự can đảm. Sự suy ngẫm này sẽ giúp bạn có buổi trị liệu đầu tiên hiệu quả hơn nhiều.",
                "metric_label": "Đã xem xét chẩn đoán & điều trị",
                "recommended_next": [
                    {
                        "slide_group_id": "medications-crisis",
                        "collection_id": "88888888-8888-8888-8888-888888888888",
                        "title": "Thuốc & Lịch sử khủng hoảng",
                        "description": "Suy ngẫm về thuốc và các khủng hoảng sức khỏe tâm thần trong quá khứ."
                    }
                ]
            }
        ]
    },
    {
        "id": "medications-crisis",
        "title": "Thuốc & Lịch sử khủng hoảng",
        "description": "Giúp nhà trị liệu hiểu lịch sử dùng thuốc và các khủng hoảng sức khỏe tâm thần trong quá khứ.",
        "position": 2,
        "slides": [
            {
                "id": "meds-why-share",
                "type": "doc",
                "title": "Tại sao nên chia sẻ thông tin thuốc",
                "content": "<h3>Tại sao nên chia sẻ thông tin thuốc</h3><p>Thuốc — cả hiện tại lẫn quá khứ — ảnh hưởng đến cách não và cơ thể bạn hoạt động. Chia sẻ điều này với nhà trị liệu giúp họ hiểu nền tảng của bạn, tránh các khuyến nghị mâu thuẫn và phối hợp với bác sĩ kê đơn nếu cần.</p>",
                "illustration": "therapy"
            },
            {
                "id": "meds-list",
                "type": "checklist_input",
                "question": "Liệt kê các thuốc sức khỏe tâm thần bạn đang hoặc đã dùng trong quá khứ.",
                "config": { "placeholder": "Ví dụ: Sertraline 50mg (2022-2023)..." }
            },
            {
                "id": "crisis-gentle-note",
                "type": "doc",
                "title": "Lưu ý trước câu hỏi tiếp theo",
                "content": "<h3>Lưu ý trước câu hỏi tiếp theo</h3><p>Câu hỏi tiếp theo về các giai đoạn khủng hoảng sức khỏe tâm thần — những lúc bạn có thể cảm thấy không thể đối phó hoặc cần hỗ trợ khẩn cấp.</p><p>Đây hoàn toàn là tùy chọn. Hãy chỉ chia sẻ những gì bạn cảm thấy thoải mái ngay lúc này.</p>"
            },
            {
                "id": "crisis-history",
                "type": "journal_prompt",
                "question": "Nếu bạn đã từng trải qua khủng hoảng sức khỏe tâm thần — hãy mô tả điều đã xảy ra và cách bạn vượt qua. (Tùy chọn — có thể bỏ qua nếu muốn.)",
                "config": { "allowAI": true }
            },
            {
                "id": "history-key-things",
                "type": "journal_prompt",
                "question": "Điều quan trọng nhất bạn muốn nhà trị liệu biết về lịch sử sức khỏe tâm thần của bạn là gì?",
                "config": { "allowAI": true, "minLength": 20 }
            },
            {
                "id": "medications-crisis-completion",
                "type": "completion",
                "title": "Bước 2 hoàn tất",
                "content": "Bạn đã suy ngẫm về lịch sử sức khỏe tâm thần. Đây là một trong những điều quý giá nhất bạn có thể mang vào buổi trị liệu.",
                "metric_label": "Đã xem xét thuốc & lịch sử khủng hoảng",
                "recommended_next": [
                    {
                        "slide_group_id": "sleep-routines",
                        "collection_id": "99999999-9999-9999-9999-999999999999",
                        "title": "Giấc ngủ & Thói quen hàng ngày",
                        "description": "Khám phá cách nhịp điệu hàng ngày của bạn ảnh hưởng đến sức khỏe tâm thần."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = '88888888-8888-8888-8888-888888888888';

UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "sleep-routines",
        "title": "Giấc ngủ & Thói quen hàng ngày",
        "description": "Hiểu cách nhịp điệu và thói quen hàng ngày của bạn ảnh hưởng đến sức khỏe tâm thần.",
        "position": 1,
        "slides": [
            {
                "id": "lifestyle-rhythms-matter",
                "type": "doc",
                "title": "Nhịp điệu hàng ngày của bạn quan trọng",
                "content": "<h3>Nhịp điệu hàng ngày của bạn quan trọng</h3><p>Giấc ngủ, dinh dưỡng, vận động và lịch trình không chỉ là chủ đề sức khỏe thể chất — chúng có liên hệ sâu sắc với tâm trạng, năng lượng và điều tiết cảm xúc.</p><p>Các nhà trị liệu thường hỏi về lối sống vì những thay đổi nhỏ ở đây có thể có tác động lớn đến cảm giác của bạn về mặt tinh thần.</p>",
                "illustration": "lifestyle"
            },
            {
                "id": "lifestyle-sleep-check",
                "type": "sleep_check",
                "question": "Bạn đánh giá chất lượng giấc ngủ của mình trong tuần qua thế nào?",
                "config": { "min": 0, "max": 100 }
            },
            {
                "id": "lifestyle-struggles-check",
                "type": "questionnaire",
                "question": "Những lĩnh vực lối sống nào bạn cảm thấy đang ảnh hưởng đến sức khỏe tâm thần?",
                "content": "Chọn tất cả những gì phù hợp.",
                "mode": "multi",
                "options": [
                    {"id": "sleep", "label": "Giấc ngủ", "description": "Khó ngủ, thức giấc, hoặc ngủ quá nhiều"},
                    {"id": "exercise", "label": "Vận động thể chất"},
                    {"id": "diet", "label": "Chế độ ăn & dinh dưỡng"},
                    {"id": "screens", "label": "Thời gian màn hình & mạng xã hội"},
                    {"id": "substances", "label": "Rượu hoặc các chất khác"},
                    {"id": "work-life", "label": "Cân bằng công việc - cuộc sống"},
                    {"id": "routine", "label": "Thiếu lịch trình sinh hoạt"},
                    {"id": "none", "label": "Không có vấn đề nào hiện tại"}
                ]
            },
            {
                "id": "lifestyle-typical-day",
                "type": "journal_prompt",
                "question": "Mô tả một ngày điển hình của bạn từ sáng đến tối. Nó hiện trông như thế nào?",
                "config": { "allowAI": true, "minLength": 30 }
            },
            {
                "id": "lifestyle-helpful-habits",
                "type": "journal_prompt",
                "question": "Những thói quen hay lịch trình nào giúp hỗ trợ sức khỏe tâm thần của bạn? Bạn muốn thay đổi điều gì?",
                "config": { "allowAI": true }
            },
            {
                "id": "sleep-routines-completion",
                "type": "completion",
                "title": "Nhận thức bản thân tuyệt vời",
                "content": "Hiểu cách thói quen hàng ngày kết nối với tâm trạng của bạn là một hiểu biết mạnh mẽ để mang vào buổi trị liệu.",
                "metric_label": "Hoàn tất suy ngẫm về giấc ngủ & thói quen",
                "recommended_next": [
                    {
                        "slide_group_id": "support-network",
                        "collection_id": "99999999-9999-9999-9999-999999999999",
                        "title": "Mạng lưới hỗ trợ của bạn",
                        "description": "Suy ngẫm về những người và kết nối bền đỡ bạn."
                    }
                ]
            }
        ]
    },
    {
        "id": "support-network",
        "title": "Mạng lưới hỗ trợ của bạn",
        "description": "Suy ngẫm về những người xung quanh và những gì bạn cần từ hệ thống hỗ trợ của mình.",
        "position": 2,
        "slides": [
            {
                "id": "support-why-matters",
                "type": "doc",
                "title": "Hỗ trợ xã hội và sức khỏe tâm thần",
                "content": "<h3>Hỗ trợ xã hội và sức khỏe tâm thần</h3><p>Nghiên cứu liên tục chứng minh rằng <strong>chỉ cần có một người đáng tin cậy</strong> để nói chuyện đã giảm đáng kể tác động của stress và các khó khăn sức khỏe tâm thần.</p><p>Nhà trị liệu sẽ muốn hiểu ai đang ở bên bạn — và đâu có thể là khoảng trống trong các mối quan hệ của bạn.</p>",
                "illustration": "support"
            },
            {
                "id": "support-who-check",
                "type": "questionnaire",
                "question": "Bạn hiện có ai trong mạng lưới hỗ trợ của mình?",
                "content": "Chọn tất cả những gì phù hợp.",
                "mode": "multi",
                "options": [
                    {"id": "family", "label": "Gia đình", "description": "Bố mẹ, anh chị em, họ hàng"},
                    {"id": "friends", "label": "Bạn bè thân thiết"},
                    {"id": "partner", "label": "Bạn đời hoặc người yêu"},
                    {"id": "therapist", "label": "Nhà trị liệu hoặc tư vấn viên hiện tại"},
                    {"id": "online", "label": "Cộng đồng trực tuyến hoặc hỗ trợ đồng đẳng"},
                    {"id": "religious", "label": "Cộng đồng tôn giáo hoặc tâm linh"},
                    {"id": "colleagues", "label": "Đồng nghiệp hoặc người mentor"},
                    {"id": "pets", "label": "Thú cưng"},
                    {"id": "none", "label": "Tôi cảm thấy không có sự hỗ trợ nào lúc này"}
                ]
            },
            {
                "id": "support-helpful",
                "type": "journal_prompt",
                "question": "Ai trong cuộc sống của bạn hiểu những gì bạn đang trải qua, hoặc cố gắng hiểu? Họ hỗ trợ bạn như thế nào?",
                "config": { "allowAI": true, "minLength": 20 }
            },
            {
                "id": "support-challenges",
                "type": "journal_prompt",
                "question": "Có ai trong cuộc sống của bạn đang làm mọi thứ khó khăn hơn không? Bạn không cần nêu tên họ — chỉ cần mô tả mối quan hệ nếu cảm thấy thoải mái.",
                "config": { "allowAI": true }
            },
            {
                "id": "support-needs",
                "type": "journal_prompt",
                "question": "Sự hỗ trợ có nghĩa gì với bạn? Bạn cần gì từ những người xung quanh?",
                "config": { "allowAI": true }
            },
            {
                "id": "support-network-completion",
                "type": "completion",
                "title": "Bước 3 hoàn tất",
                "content": "Hiểu hệ thống hỗ trợ của bạn giúp nhà trị liệu hiểu thế giới của bạn rõ hơn. Bạn gần như đã sẵn sàng cho buổi trị liệu.",
                "metric_label": "Hoàn tất suy ngẫm về mạng lưới hỗ trợ",
                "recommended_next": [
                    {
                        "slide_group_id": "stress-check-in",
                        "collection_id": "44444444-4444-4444-4444-444444444444",
                        "title": "Chuẩn bị cho buổi trị liệu",
                        "description": "Bước cuối cùng — chuẩn bị để bước vào buổi trị liệu với sự tự tin."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = '99999999-9999-9999-9999-999999999999';
