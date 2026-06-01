-- Migration 000037: Fix Vietnamese translations — natural tone for all 12 collections
-- Principle: "mình" instead of "tôi", natural phrasing, not literal translations

-- ============================================================================
-- Collection 1: Daily Reflection (55555555)
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "morning-prep",
        "title": "Buổi sáng",
        "description": "Bắt đầu ngày mới với việc viết nhật ký có ý thức và tập trung tích cực.",
        "position": 1,
        "slides": [
            {
                "id": "morning-mood",
                "type": "emotion_log",
                "question": "Bạn cảm thấy thế nào sáng nay?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Bão tố", "Mưa to", "Mưa", "Nhiều mây", "Mây rải rác", "Hầu hết nắng", "Nắng", "Sáng rỡ", "Rạng ngời", "Hạnh phúc"]
                }
            },
            {
                "id": "morning-sleep",
                "type": "sleep_check",
                "question": "Bạn đã ngủ bao nhiêu tiếng tối qua?",
                "config": { "min": 0, "max": 12 }
            },
            {
                "id": "morning-mind",
                "type": "journal_prompt",
                "question": "Sáng nay trong đầu mình đang nghĩ gì?",
                "config": { "allowAI": true, "minLength": 20 }
            },
            {
                "id": "morning-intentions",
                "type": "journal_prompt",
                "question": "Mình có thể làm gì để hôm nay thật ý nghĩa?",
                "config": { "allowAI": true, "minLength": 20 }
            },
            {
                "id": "morning-cta-gratitude",
                "type": "cta",
                "title": "Bắt đầu với lòng biết ơn",
                "content": "Một bài tập biết ơn ngắn có thể tạo nên tâm trạng tích cực cho ngày mới.",
                "config": {
                    "slide_group_id": "daily-gratitude",
                    "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555"
                }
            },
            {
                "id": "morning-completion",
                "type": "completion",
                "title": "Ghi nhận buổi sáng hoàn tất!",
                "content": "Bạn đã đặt mục tiêu cho ngày hôm nay. Hãy quay lại buổi tối để suy ngẫm.",
                "metric_label": "Suy ngẫm buổi sáng hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "evening-reflection",
                        "collection_id": "55555555-5555-5555-5555-555555555555",
                        "title": "Suy ngẫm buổi tối",
                        "description": "Kết thúc ngày với sự suy ngẫm và tự thương yêu."
                    },
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Biết ơn hàng ngày",
                        "description": "Thực hành đơn giản để nhận ra những điều tốt đẹp trong cuộc sống."
                    }
                ]
            }
        ]
    },
    {
        "id": "evening-reflection",
        "title": "Buổi tối",
        "description": "Kết thúc ngày với sự suy ngẫm và tự thương yêu.",
        "position": 2,
        "slides": [
            {
                "id": "evening-mood",
                "type": "emotion_log",
                "question": "Bạn cảm thấy thế nào tối nay?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Bão tố", "Mưa to", "Mưa", "Nhiều mây", "Mây rải rác", "Hầu hết nắng", "Nắng", "Sáng rỡ", "Rạng ngời", "Hạnh phúc"]
                }
            },
            {
                "id": "evening-sleep-quality",
                "type": "sleep_check",
                "question": "Bạn đánh giá mức năng lượng của mình hôm nay thế nào?",
                "config": { "min": 0, "max": 100 }
            },
            {
                "id": "evening-memorable",
                "type": "journal_prompt",
                "question": "Điều gì đáng nhớ đã xảy ra hôm nay?",
                "config": { "allowAI": true }
            },
            {
                "id": "evening-positive",
                "type": "journal_prompt",
                "question": "Điều gì đã diễn ra tốt đẹp hôm nay?",
                "config": { "allowAI": true }
            },
            {
                "id": "evening-learning",
                "type": "journal_prompt",
                "question": "Hôm nay mình đã học được gì?",
                "config": { "allowAI": true }
            },
            {
                "id": "evening-changes",
                "type": "journal_prompt",
                "question": "Nếu được làm lại, mình muốn thay đổi điều gì hôm nay?",
                "config": { "allowAI": true }
            },
            {
                "id": "evening-celebrate",
                "type": "journal_prompt",
                "question": "Hôm nay có gì đáng ăn mừng không?",
                "config": { "allowAI": true }
            },
            {
                "id": "evening-day-rating",
                "type": "star_rating",
                "question": "Bạn đánh giá ngày hôm nay thế nào?",
                "config": { "min": 1, "max": 5 }
            },
            {
                "id": "evening-winddown",
                "type": "journal_prompt",
                "question": "Mình có thể làm gì để thư giãn và buông bỏ hết một ngày?",
                "config": { "allowAI": true }
            },
            {
                "id": "evening-completion",
                "type": "completion",
                "title": "Ngày hoàn tất!",
                "content": "Bạn đã suy ngẫm về ngày hôm nay. Hãy nghỉ ngơi tốt tối nay.",
                "metric_label": "Suy ngẫm buổi tối hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Hiểu về cảm xúc",
                        "description": "Tìm hiểu về cảm xúc và cách làm việc cùng chúng."
                    },
                    {
                        "slide_group_id": "why-sleep-matters",
                        "collection_id": "cccc3333-cccc-4333-cccc-cccccccc3333",
                        "title": "Tại sao giấc ngủ quan trọng",
                        "description": "Tìm hiểu vai trò quan trọng của giấc ngủ đối với sức khỏe."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = '55555555-5555-5555-5555-555555555555';


-- ============================================================================
-- Collection 2: Therapy Preparation (33333333)
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "signs-need-therapy",
        "title": "Dấu hiệu bạn cần trị liệu",
        "description": "Nhận biết khi nào có thể là lúc bạn cần tìm kiếm hỗ trợ chuyên nghiệp.",
        "position": 1,
        "slides": [
            {
                "id": "sign-tearful",
                "type": "doc",
                "title": "Bạn hay khóc mà không rõ lý do",
                "content": "<h3>Bạn hay khóc mà không rõ lý do</h3><p>Khi làm những hoạt động hàng ngày như đọc sách hay xem phim, nếu bạn thấy mình khóc mà không rõ lý do, đó có thể là dấu hiệu cảm xúc đang quá tải và bạn cần ai đó để trò chuyện.</p>"
            },
            {
                "id": "sign-negative",
                "type": "doc",
                "title": "Bạn luôn có cảm xúc tiêu cực",
                "content": "<h3>Bạn luôn có cảm xúc tiêu cực</h3><p>Những cảm xúc tiêu cực kéo dài có thể đè nặng và có thể là tín hiệu cho thấy sự hỗ trợ chuyên nghiệp có thể giúp ích.</p>"
            },
            {
                "id": "sign-habits",
                "type": "doc",
                "title": "Bạn quay lại những thói quen không lành mạnh",
                "content": "<h3>Bạn quay lại những thói quen không lành mạnh</h3><p>Rơi vào những thói quen cũ không lành mạnh có thể là dấu hiệu của những vấn đề sâu xa hơn mà trị liệu có thể giúp giải quyết.</p>"
            },
            {
                "id": "sign-control",
                "type": "doc",
                "title": "Bạn cảm thấy cảm xúc đang kiểm soát mình",
                "content": "<h3>Bạn cảm thấy cảm xúc đang kiểm soát mình</h3><p>Những trải nghiệm như bùng nổ giận dữ, la hét, hay suy nghĩ không ngừng về thất bại trong quá khứ có thể ảnh hưởng đến giấc ngủ và cuộc sống hàng ngày. Đây có thể là tín hiệu bạn cần hỗ trợ.</p>"
            },
            {
                "id": "sign-disconnected",
                "type": "doc",
                "title": "Bạn cảm thấy mất kết nối giữa thế giới bên trong và bên ngoài",
                "content": "<h3>Bạn cảm thấy mất kết nối giữa thế giới bên trong và bên ngoài</h3><p>Bạn có thể tỏ ra vui vẻ trong xã hội nhưng cảm thấy rất khác bên trong. Có hai khuôn mặt khác nhau có thể cho thấy sự mất kết nối.</p>"
            },
            {
                "id": "sign-relationships",
                "type": "doc",
                "title": "Các mối quan hệ đang gặp khó khăn",
                "content": "<h3>Các mối quan hệ đang gặp khó khăn</h3><p>Khi bạn cảm thấy xa cách bạn bè hay gia đình, điều đó có thể chỉ ra vấn đề về niềm tin, lòng tự trọng, hoặc những khó khăn cảm xúc sâu xa hơn.</p>"
            },
            {
                "id": "sign-self-check",
                "type": "questionnaire",
                "question": "Dấu hiệu nào phù hợp với bạn?",
                "content": "Chọn tất cả những gì phù hợp. Không có câu trả lời đúng hay sai.",
                "mode": "multi",
                "options": [
                    {"id": "tearful", "label": "Hay khóc mà không rõ lý do"},
                    {"id": "negative", "label": "Cảm xúc tiêu cực kéo dài"},
                    {"id": "habits", "label": "Quay lại thói quen không lành mạnh"},
                    {"id": "control", "label": "Cảm xúc mất kiểm soát"},
                    {"id": "disconnected", "label": "Cảm thấy mất kết nối bên trong và bên ngoài"},
                    {"id": "relationships", "label": "Các mối quan hệ đang gặp khó khăn"}
                ]
            },
            {
                "id": "sign-reminder",
                "type": "doc",
                "title": "Lời nhắc nhở",
                "content": "<h3>Lời nhắc nhở</h3><p>Đây chỉ là những dấu hiệu phổ biến — bạn không cần phải có bất kỳ dấu hiệu nào trong số này để gặp nhà trị liệu. Tất cả những gì bạn cần là mong muốn cảm thấy tốt hơn và chia sẻ những gì trong lòng.</p>"
            },
            {
                "id": "therapy-reflection",
                "type": "journal_prompt",
                "question": "Sau khi đọc những dấu hiệu này, điều gì phù hợp với bạn? Bạn đang cảm thấy gì ngay bây giờ?",
                "config": { "allowAI": true, "minLength": 30 }
            },
            {
                "id": "signs-completion",
                "type": "completion",
                "title": "Bạn đã dũng cảm bước tới",
                "content": "Nhận ra những dấu hiệu này cần sự dũng cảm. Hiểu bản thân hơn là bước đầu tiên để cảm thấy tốt hơn.",
                "metric_label": "Bài tập nhận thức bản thân hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "what-to-know",
                        "collection_id": "33333333-3333-3333-3333-333333333333",
                        "title": "Điều tôi muốn nhà trị liệu biết",
                        "description": "Chuẩn bị những gì bạn muốn chia sẻ trong buổi đầu tiên."
                    },
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Hiểu về cảm xúc",
                        "description": "Tìm hiểu tại sao cảm xúc quan trọng và cách làm việc cùng chúng."
                    }
                ]
            }
        ]
    },
    {
        "id": "what-to-know",
        "title": "Điều tôi muốn nhà trị liệu biết",
        "description": "Suy ngẫm về những gì bạn muốn chia sẻ trong buổi trị liệu đầu tiên.",
        "position": 2,
        "slides": [
            {
                "id": "therapist-know-intro",
                "type": "doc",
                "title": "Chuẩn bị cho buổi đầu tiên",
                "content": "<h3>Chuẩn bị cho buổi đầu tiên</h3><p>Trị liệu có thể cảm thấy choáng ngợp lúc đầu. Dành thời gian suy ngẫm về những gì bạn muốn chia sẻ có thể giúp bạn cảm thấy chuẩn bị và tự tin hơn.</p><p>Hãy sử dụng những câu hỏi này để khám phá điều gì quan trọng nhất với bạn ngay bây giờ.</p>"
            },
            {
                "id": "therapist-appointment-date",
                "type": "date_picker",
                "question": "Cuộc hẹn trị liệu của bạn vào khi nào?",
                "config": { "format": "YYYY-MM-DD" }
            },
            {
                "id": "therapist-main-concern",
                "type": "journal_prompt",
                "question": "Điều gì khiến bạn quyết định đi trị liệu lúc này?",
                "config": { "allowAI": true, "minLength": 30 }
            },
            {
                "id": "therapist-goals",
                "type": "journal_prompt",
                "question": "Bạn hy vọng đạt được gì qua trị liệu?",
                "config": { "allowAI": true }
            },
            {
                "id": "therapist-struggles",
                "type": "journal_prompt",
                "question": "Điều gì khó khăn nhất với bạn gần đây?",
                "config": { "allowAI": true }
            },
            {
                "id": "therapist-things-to-bring",
                "type": "checklist_input",
                "question": "Bạn muốn nhớ đề cập điều gì trong buổi trị liệu?",
                "config": { "placeholder": "Thêm chủ đề hoặc câu hỏi..." }
            },
            {
                "id": "therapist-support",
                "type": "journal_prompt",
                "question": "Bạn thấy kiểu hỗ trợ nào sẽ giúp mình nhất?",
                "config": { "allowAI": true }
            },
            {
                "id": "therapist-cta-anxiety",
                "type": "cta",
                "title": "Cảm thấy lo lắng về trị liệu?",
                "content": "Tìm hiểu kỹ thuật cân bằng để giúp bạn cảm thấy bình tĩnh hơn.",
                "config": {
                    "slide_group_id": "grounding-techniques",
                    "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222"
                }
            },
            {
                "id": "what-to-know-completion",
                "type": "completion",
                "title": "Bạn đã sẵn sàng",
                "content": "Bạn đã thực hiện một bước có ý nghĩa trong việc chuẩn bị cho trị liệu. Sắp xếp suy nghĩ có thể giúp buổi trị liệu hiệu quả hơn nhiều.",
                "metric_label": "Chuẩn bị trị liệu hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "what-is-anxiety",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Hiểu về lo âu",
                        "description": "Tìm hiểu về lo âu và sự khác biệt với lo lắng thông thường."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Yêu thương bản thân",
                        "description": "Học cách đối xử tử tế với bản thân."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = '33333333-3333-3333-3333-333333333333';


-- ============================================================================
-- Collection 3: Stress Management (44444444)
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "stress-check-in",
        "title": "Kiểm tra căng thẳng",
        "description": "Đánh giá mức căng thẳng hiện tại và xác định nguyên nhân.",
        "position": 1,
        "slides": [
            {
                "id": "stress-intro",
                "type": "doc",
                "title": "Hiểu về căng thẳng của bạn",
                "content": "<h3>Hiểu về căng thẳng của bạn</h3><p>Căng thẳng là phản ứng tự nhiên, nhưng căng thẳng mãn tính có thể gây hại cho tâm trí và cơ thể. Bài kiểm tra này giúp bạn <strong>nhận diện</strong> nguyên nhân gây căng thẳng và <strong>lên kế hoạch</strong> một bước nhỏ để giảm bớt.</p>"
            },
            {
                "id": "stress-level",
                "type": "emotion_log",
                "question": "Bạn đang cảm thấy căng thẳng ở mức nào?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Bình tĩnh", "Thư giãn", "Thoải mái", "Hơi căng", "Vừa phải", "Căng thẳng", "Rất căng thẳng", "Quá tải", "Cực độ", "Đến giới hạn"]
                }
            },
            {
                "id": "stress-type-check",
                "type": "questionnaire",
                "question": "Bạn đang trải qua loại căng thẳng nào?",
                "content": "Chọn nguồn căng thẳng chính của bạn ngay bây giờ.",
                "mode": "single",
                "options": [
                    {"id": "work", "label": "Công việc hoặc học tập", "description": "Deadline, khối lượng công việc, áp lực hiệu suất"},
                    {"id": "relationships", "label": "Mối quan hệ", "description": "Xung đột, cô đơn, áp lực xã hội"},
                    {"id": "health", "label": "Sức khỏe", "description": "Sức khỏe thể chất, tinh thần, giấc ngủ"},
                    {"id": "financial", "label": "Tài chính", "description": "Lo lắng tiền bạc, hóa đơn, an ninh công việc"},
                    {"id": "life-changes", "label": "Thay đổi cuộc sống", "description": "Chuyển nhà, công việc mới, mất mát, chuyển đổi"},
                    {"id": "general", "label": "Quá tải chung", "description": "Mọi thứ cảm thấy quá nhiều"}
                ]
            },
            {
                "id": "stress-sources",
                "type": "journal_prompt",
                "question": "Điều gì đang làm bạn căng thẳng lúc này?",
                "config": { "allowAI": true, "minLength": 20 }
            },
            {
                "id": "stress-body",
                "type": "journal_prompt",
                "question": "Căng thẳng ảnh hưởng đến cơ thể bạn ra sao?",
                "config": { "allowAI": true }
            },
            {
                "id": "stress-coping",
                "type": "journal_prompt",
                "question": "Điều gì đã giúp bạn đối phó với căng thẳng trước đây?",
                "config": { "allowAI": true }
            },
            {
                "id": "stress-action",
                "type": "journal_prompt",
                "question": "Hôm nay mình có thể làm một điều nhỏ nào để bớt căng thẳng?",
                "config": { "allowAI": true }
            },
            {
                "id": "stress-cta-anxiety",
                "type": "cta",
                "title": "Cảm thấy lo âu cùng với căng thẳng?",
                "content": "Tìm hiểu kỹ thuật được thiết kế riêng để quản lý suy nghĩ lo âu.",
                "config": {
                    "slide_group_id": "challenging-thoughts",
                    "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222"
                }
            },
            {
                "id": "stress-checkin-completion",
                "type": "completion",
                "title": "Kiểm tra hoàn tất",
                "content": "Bạn đã nhận diện căng thẳng và lên kế hoạch bước tiếp theo. Nhận thức đó rất có sức mạnh.",
                "metric_label": "Kiểm tra căng thẳng hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "grounding-techniques",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Kỹ thuật cân bằng",
                        "description": "Kỹ thuật thực tế để trấn an hệ thần kinh."
                    },
                    {
                        "slide_group_id": "what-is-mindfulness",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Chánh niệm là gì?",
                        "description": "Học chánh niệm cho sự bình tĩnh hiện tại."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = '44444444-4444-4444-4444-444444444444';


-- ============================================================================
-- Collection 4: Introduction to Journaling (22222222)
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "what-is-journaling",
        "title": "Viết nhật ký là gì?",
        "description": "Tìm hiểu viết nhật ký là gì, tại sao nó quan trọng và ứng dụng hỗ trợ bạn ra sao.",
        "position": 1,
        "slides": [
            {
                "id": "journaling-intro",
                "type": "doc",
                "title": "Viết nhật ký là gì",
                "content": "<h3>Viết nhật ký là gì</h3><p>Viết nhật ký đơn giản là ghi lại <strong>suy nghĩ</strong>, <strong>cảm xúc</strong> và <strong>trải nghiệm</strong> — giống như một cuộc trò chuyện yên tĩnh với bản thân trong sổ tay hoặc trên điện thoại.</p>"
            },
            {
                "id": "journaling-why",
                "type": "doc",
                "title": "Tại sao nó quan trọng",
                "content": "<h3>Tại sao nó quan trọng</h3><p>Viết ra giúp bạn <strong>bày tỏ bản thân</strong> và <strong>nhận ra suy nghĩ</strong> rõ ràng hơn. Hãy nghĩ cảm xúc như những vị khách — viết nhật ký cho phép bạn đón tiếp, lắng nghe và để chúng đi.</p>"
            },
            {
                "id": "journaling-app",
                "type": "doc",
                "title": "Ứng dụng hỗ trợ bạn như thế nào",
                "content": "<h3>Ứng dụng hỗ trợ bạn như thế nào</h3><p>Tại đây, bạn sẽ tìm thấy <strong>câu hỏi hàng ngày</strong> để suy ngẫm về cảm xúc, cùng với <strong>tài nguyên</strong> giúp bạn cảm thấy chuẩn bị và được hỗ trợ hơn.</p>"
            },
            {
                "id": "journaling-further",
                "type": "further_reading",
                "title": "Tìm hiểu thêm",
                "content": "<h3>Đọc thêm</h3><ul><li><a href='https://dayoneapp.com/blog/journaling/'>What is Journaling - DayOne</a></li></ul>"
            },
            {
                "id": "journaling-what-completion",
                "type": "completion",
                "title": "Khởi đầu tuyệt vời!",
                "content": "Bây giờ bạn đã biết viết nhật ký là gì. Tiếp theo, hãy tìm hiểu về những lợi ích mạnh mẽ mà nó mang lại.",
                "metric_label": "Bài học hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "benefits-journaling",
                        "collection_id": "22222222-2222-2222-2222-222222222222",
                        "title": "Lợi ích của viết nhật ký",
                        "description": "Khám phá cách viết nhật ký hỗ trợ sức khỏe tinh thần."
                    },
                    {
                        "slide_group_id": "morning-prep",
                        "collection_id": "55555555-5555-5555-5555-555555555555",
                        "title": "Suy ngẫm buổi sáng",
                        "description": "Thử viết nhật ký đầu tiên với câu hỏi buổi sáng."
                    }
                ]
            }
        ]
    },
    {
        "id": "benefits-journaling",
        "title": "Lợi ích của viết nhật ký",
        "description": "Khám phá cách viết nhật ký hỗ trợ sức khỏe tinh thần và cảm xúc.",
        "position": 2,
        "slides": [
            {
                "id": "benefit-awareness",
                "type": "doc",
                "title": "Thúc đẩy nhận thức bản thân",
                "content": "<h3>Thúc đẩy nhận thức bản thân và suy ngẫm</h3><p>Ghi lại suy nghĩ và cảm xúc giúp nhận diện các khuôn mẫu, yếu tố kích hoạt và hành vi, nâng cao sự hiểu biết và nhận thức bản thân. Điều này cũng giúp theo dõi tiến trình sức khỏe tinh thần.</p>"
            },
            {
                "id": "benefit-stress",
                "type": "doc",
                "title": "Giảm căng thẳng và lo âu",
                "content": "<h3>Giảm căng thẳng và lo âu</h3><p>Viết nhật ký là trải nghiệm giải tỏa giúp giải phóng cảm xúc tích tụ và giảm mức hormone căng thẳng, mang lại cảm giác kiểm soát và chủ động hơn với cảm xúc của mình.</p>"
            },
            {
                "id": "benefit-outlet",
                "type": "doc",
                "title": "Nơi an toàn cho cảm xúc",
                "content": "<h3>Nơi an toàn cho cảm xúc</h3><p>Viết nhật ký cung cấp không gian riêng tư, không phán xét để bày tỏ cảm xúc, đặc biệt hữu ích trong quản lý trầm cảm và lo âu.</p>"
            },
            {
                "id": "benefit-mood",
                "type": "doc",
                "title": "Cải thiện tâm trạng",
                "content": "<h3>Cải thiện tâm trạng và sự tích cực</h3><p>Viết về trải nghiệm tích cực và lòng biết ơn có thể tăng hạnh phúc, chống lại khuôn mẫu suy nghĩ tiêu cực và cải thiện sức khỏe cảm xúc tổng thể.</p>"
            },
            {
                "id": "benefit-reflect",
                "type": "journal_prompt",
                "question": "Bạn hy vọng viết nhật ký sẽ mang lại điều gì cho mình?",
                "config": { "allowAI": true }
            },
            {
                "id": "benefit-cta-daily",
                "type": "cta",
                "title": "Sẵn sàng bắt đầu viết nhật ký?",
                "content": "Thử suy ngẫm hàng ngày đơn giản để áp dụng những gì bạn đã học.",
                "config": {
                    "slide_group_id": "morning-prep",
                    "collection_id": "55555555-5555-5555-5555-555555555555"
                }
            },
            {
                "id": "benefits-completion",
                "type": "completion",
                "title": "Bạn đã sẵn sàng bắt đầu!",
                "content": "Bạn đã hiểu tại sao viết nhật ký quan trọng. Thời điểm tốt nhất để bắt đầu là hôm nay.",
                "metric_label": "Giới thiệu hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "morning-prep",
                        "collection_id": "55555555-5555-5555-5555-555555555555",
                        "title": "Suy ngẫm buổi sáng",
                        "description": "Bắt đầu viết nhật ký đầu tiên với câu hỏi hướng dẫn."
                    },
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Hiểu về cảm xúc",
                        "description": "Tìm hiểu về cảm xúc để viết nhật ký sâu sắc hơn."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = '22222222-2222-2222-2222-222222222222';


-- ============================================================================
-- Collection 5: Understanding Anxiety (bbbb2222)
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "what-is-anxiety",
        "title": "Lo âu là gì?",
        "description": "Hiểu bản chất của lo âu và sự khác biệt so với lo lắng thông thường.",
        "position": 1,
        "slides": [
            {
                "id": "anxiety-natural",
                "type": "doc",
                "title": "Lo âu là phản ứng tự nhiên",
                "content": "<h3>Lo âu là phản ứng tự nhiên</h3><p>Lo âu là <strong>hệ thống báo động</strong> của cơ thể. Nó được thiết kế để bảo vệ bạn khỏi nguy hiểm bằng cách kích hoạt phản ứng chiến-hoặc-chạy. Vấn đề xảy ra khi báo động này kêu quá thường xuyên hoặc quá mạnh.</p>"
            },
            {
                "id": "anxiety-vs-worry",
                "type": "doc",
                "title": "Lo lắng vs. Lo âu",
                "content": "<h3>Lo lắng vs. Lo âu</h3><p><strong>Lo lắng</strong> là về tinh thần — là những suy nghĩ về điều gì có thể sai. <strong>Lo âu</strong> là về thể chất — là nhịp tim nhanh, ngực chặt và lòng bàn tay đổ mồ hôi đi kèm những suy nghĩ đó.</p>"
            },
            {
                "id": "anxiety-symptoms",
                "type": "doc",
                "title": "Triệu chứng phổ biến",
                "content": "<h3>Triệu chứng phổ biến</h3><ul><li>Suy nghĩ chạy đua và khó tập trung</li><li>Bồn chồn và cảm giác bất an</li><li>Căng cơ và đau đầu</li><li>Khó ngủ</li><li>Tránh né các tình huống kích hoạt</li></ul>"
            },
            {
                "id": "anxiety-level-check",
                "type": "questionnaire",
                "question": "Bạn mô tả lo âu của mình hiện tại như thế nào?",
                "content": "Chọn câu mô tả đúng nhất với mình lúc này.",
                "mode": "single",
                "options": [
                    {"id": "minimal", "label": "Rất ít", "description": "Tôi cảm thấy khá bình tĩnh, thỉnh thoảng mới lo lắng"},
                    {"id": "mild", "label": "Nhẹ", "description": "Tôi nhận thấy lo âu nhưng nó không ảnh hưởng nhiều"},
                    {"id": "moderate", "label": "Vừa phải", "description": "Lo âu đôi khi ảnh hưởng đến hoạt động hàng ngày"},
                    {"id": "significant", "label": "Nhiều", "description": "Lo âu luôn hiện diện trong cuộc sống"}
                ]
            },
            {
                "id": "anxiety-what-completion",
                "type": "completion",
                "title": "Kiến thức là sức mạnh",
                "content": "Hiểu về lo âu là bước đầu tiên để quản lý nó. Bạn đang học những kỹ năng quan trọng.",
                "metric_label": "Bài học hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "anxiety-triggers",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Nhận diện yếu tố kích hoạt",
                        "description": "Tìm hiểu tình huống nào kích hoạt lo âu của bạn."
                    },
                    {
                        "slide_group_id": "grounding-techniques",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Kỹ thuật cân bằng",
                        "description": "Kỹ thuật thực tế khi lo âu xuất hiện."
                    }
                ]
            }
        ]
    },
    {
        "id": "anxiety-triggers",
        "title": "Nhận diện yếu tố kích hoạt",
        "description": "Nhận biết tình huống, suy nghĩ hoặc khuôn mẫu nào kích hoạt lo âu.",
        "position": 2,
        "slides": [
            {
                "id": "triggers-what",
                "type": "doc",
                "title": "Yếu tố kích hoạt là gì?",
                "content": "<h3>Yếu tố kích hoạt là gì?</h3><p>Yếu tố kích hoạt là tình huống, suy nghĩ hoặc cảm giác kích hoạt phản ứng lo âu. Chúng có thể từ <strong>bên ngoài</strong> (deadline, sự kiện xã hội) hoặc <strong>bên trong</strong> (suy nghĩ, cảm giác thể chất, ký ức).</p>"
            },
            {
                "id": "triggers-common",
                "type": "doc",
                "title": "Yếu tố kích hoạt lo âu phổ biến",
                "content": "<h3>Yếu tố kích hoạt lo âu phổ biến</h3><ul><li>Sự không chắc chắn về tương lai</li><li>Tình huống xã hội và sợ bị đánh giá</li><li>Lo ngại sức khỏe</li><li>Lo lắng tài chính</li><li>Xung đột trong mối quan hệ</li><li>Chấn thương quá khứ hoặc ký ức khó khăn</li></ul>"
            },
            {
                "id": "triggers-reflect",
                "type": "journal_prompt",
                "question": "Tình huống nào thường làm mình lo âu nhất?",
                "config": { "allowAI": true, "minLength": 20 }
            },
            {
                "id": "triggers-pattern",
                "type": "journal_prompt",
                "question": "Mình có nhận ra quy luật nào khi lo âu hay xuất hiện không?",
                "config": { "allowAI": true }
            },
            {
                "id": "triggers-completion",
                "type": "completion",
                "title": "Tuyệt! Bạn đã hiểu thêm về mình",
                "content": "Biết yếu tố kích hoạt giúp bạn chuẩn bị và phản hồi thay vì phản ứng.",
                "metric_label": "Đã nhận diện yếu tố kích hoạt",
                "recommended_next": [
                    {
                        "slide_group_id": "grounding-techniques",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Kỹ thuật cân bằng",
                        "description": "Kỹ thuật thực tế để trấn an hệ thần kinh."
                    },
                    {
                        "slide_group_id": "challenging-thoughts",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Thách thức suy nghĩ lo âu",
                        "description": "Học cách thay đổi khuôn mẫu suy nghĩ thúc đẩy lo âu."
                    }
                ]
            }
        ]
    },
    {
        "id": "grounding-techniques",
        "title": "Kỹ thuật cân bằng",
        "description": "Kỹ thuật thực tế để trấn an hệ thần kinh khi lo âu xuất hiện.",
        "position": 3,
        "slides": [
            {
                "id": "grounding-54321",
                "type": "doc",
                "title": "Kỹ thuật 5-4-3-2-1",
                "content": "<h3>Kỹ thuật 5-4-3-2-1</h3><p>Khi lo âu lấn át, hãy dùng giác quan để cân bằng: Kể tên <strong>5 thứ bạn nhìn thấy</strong>, <strong>4 thứ bạn chạm được</strong>, <strong>3 thứ bạn nghe được</strong>, <strong>2 thứ bạn ngửi được</strong>, và <strong>1 thứ bạn nếm được</strong>.</p>"
            },
            {
                "id": "grounding-box",
                "type": "doc",
                "title": "Thở vuông",
                "content": "<h3>Thở vuông</h3><p>Hít vào đếm 4, giữ đếm 4, thở ra đếm 4, giữ đếm 4. Lặp lại cho đến khi bình tĩnh hơn. Kỹ thuật này kích hoạt hệ thần kinh đối giao cảm.</p>"
            },
            {
                "id": "grounding-physical",
                "type": "doc",
                "title": "Cân bằng thể chất",
                "content": "<h3>Cân bằng thể chất</h3><p>Ấn chân xuống sàn, bóp quả bóng giảm stress, hoặc cầm thứ gì lạnh. Cảm giác thể chất giúp đưa bạn trở lại khoảnh khắc hiện tại.</p>"
            },
            {
                "id": "grounding-cta-mindfulness",
                "type": "cta",
                "title": "Muốn thực hành sâu hơn?",
                "content": "Thử quét cơ thể có hướng dẫn để trải nghiệm cân bằng toàn diện hơn.",
                "config": {
                    "slide_group_id": "body-scan",
                    "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777"
                }
            },
            {
                "id": "grounding-completion",
                "type": "completion",
                "title": "Đã học kỹ thuật",
                "content": "Bạn đã có công cụ thực tế để sử dụng khi lo âu xuất hiện. Thực hành sẽ giúp chúng hiệu quả hơn.",
                "metric_label": "Đã học kỹ thuật cân bằng",
                "recommended_next": [
                    {
                        "slide_group_id": "challenging-thoughts",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Thách thức suy nghĩ lo âu",
                        "description": "Nhận diện và thay đổi những cách nghĩ sai lệch."
                    },
                    {
                        "slide_group_id": "mindful-breathing",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Thở chánh niệm",
                        "description": "Thực hành thở sâu hơn cho sự bình tĩnh hàng ngày."
                    }
                ]
            }
        ]
    },
    {
        "id": "challenging-thoughts",
        "title": "Thách thức suy nghĩ lo âu",
        "description": "Nhận diện và thay đổi khuôn mẫu suy nghĩ thúc đẩy lo âu.",
        "position": 4,
        "slides": [
            {
                "id": "thoughts-distortions",
                "type": "doc",
                "title": "Lỗi suy nghĩ phổ biến",
                "content": "<h3>Lỗi suy nghĩ phổ biến</h3><p>Lo âu thường liên quan đến <strong>lỗi suy nghĩ</strong> như: nghĩ đến tình huống tồi tệ nhất (thảm họa hoá), cho rằng người khác đang đánh giá mình (đọc tâm lý), và suy nghĩ trắng đen (tất cả hoặc không gì).</p>"
            },
            {
                "id": "thoughts-question",
                "type": "doc",
                "title": "Phương pháp đặt câu hỏi",
                "content": "<h3>Phương pháp đặt câu hỏi</h3><p>Khi nhận thấy suy nghĩ lo âu, hãy tự hỏi: <em>Suy nghĩ này dựa trên sự thật hay cảm xúc? Bằng chứng ủng hộ và phản bác là gì? Tôi sẽ nói gì với bạn bè nếu họ trong tình huống này?</em></p>"
            },
            {
                "id": "thoughts-recurring",
                "type": "journal_prompt",
                "question": "Suy nghĩ lo âu nào cứ quẩn quanh trong đầu mình?",
                "config": { "allowAI": true }
            },
            {
                "id": "thoughts-evidence",
                "type": "journal_prompt",
                "question": "Mình có bằng chứng gì cho thấy suy nghĩ này có thể không hoàn toàn đúng?",
                "config": { "allowAI": true }
            },
            {
                "id": "thoughts-completion",
                "type": "completion",
                "title": "Đã thách thức suy nghĩ",
                "content": "Bạn đang xây dựng kỹ năng đặt câu hỏi về suy nghĩ lo âu. Điều này sẽ dễ hơn với thực hành.",
                "metric_label": "Hoàn tất tất cả bài học Hiểu về lo âu",
                "recommended_next": [
                    {
                        "slide_group_id": "stress-check-in",
                        "collection_id": "44444444-4444-4444-4444-444444444444",
                        "title": "Kiểm tra căng thẳng",
                        "description": "Đánh giá mức căng thẳng và lên kế hoạch đối phó."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Yêu thương bản thân",
                        "description": "Học đối xử tử tế với bản thân trong lúc khó khăn."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222';


-- ============================================================================
-- Collection 6: Better Sleep (cccc3333)
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "why-sleep-matters",
        "title": "Tại sao giấc ngủ quan trọng",
        "description": "Hiểu vai trò thiết yếu của giấc ngủ đối với sức khỏe thể chất và tinh thần.",
        "position": 1,
        "slides": [
            {
                "id": "sleep-not-optional",
                "type": "doc",
                "title": "Giấc ngủ không phải tùy chọn",
                "content": "<h3>Giấc ngủ không phải tùy chọn</h3><p>Giấc ngủ là lúc não bộ <strong>củng cố ký ức</strong>, <strong>xử lý cảm xúc</strong> và <strong>tái tạo tế bào</strong>. Thiếu ngủ không chỉ khiến bạn mệt mỏi — nó ảnh hưởng đến tâm trạng, khả năng ra quyết định và cả hệ miễn dịch.</p>"
            },
            {
                "id": "sleep-mental",
                "type": "doc",
                "title": "Mối liên hệ giữa giấc ngủ và sức khỏe tinh thần",
                "content": "<h3>Mối liên hệ giữa giấc ngủ và sức khỏe tinh thần</h3><p>Giấc ngủ và sức khỏe tinh thần có mối liên hệ sâu sắc. Lo âu và trầm cảm có thể làm gián đoạn giấc ngủ, và ngủ kém lại càng làm trầm trọng thêm lo âu và trầm cảm. Phá vỡ vòng tròn này là chìa khóa để cảm thấy tốt hơn.</p>"
            },
            {
                "id": "sleep-how-much",
                "type": "doc",
                "title": "Bạn cần ngủ bao nhiêu tiếng?",
                "content": "<h3>Bạn cần ngủ bao nhiêu tiếng?</h3><p>Hầu hết người trưởng thành cần <strong>7-9 tiếng</strong> ngủ chất lượng. Không chỉ số lượng — chất lượng giấc ngủ cũng quan trọng. Giấc ngủ sâu và giấc ngủ REM là thiết yếu để phục hồi.</p>"
            },
            {
                "id": "sleep-quality-check",
                "type": "sleep_check",
                "question": "Bạn đánh giá chất lượng giấc ngủ tổng thể của mình tuần này thế nào?",
                "config": { "min": 0, "max": 100 }
            },
            {
                "id": "sleep-matters-completion",
                "type": "completion",
                "title": "Đã nắm được!",
                "content": "Hiểu tại sao giấc ngủ quan trọng là bước đầu tiên để ngủ tốt hơn.",
                "metric_label": "Hoàn tất bài học",
                "recommended_next": [
                    {
                        "slide_group_id": "sleep-hygiene",
                        "collection_id": "cccc3333-cccc-4333-cccc-cccccccc3333",
                        "title": "Vệ sinh giấc ngủ cơ bản",
                        "description": "Những thói quen đơn giản giúp bạn ngủ ngon hơn."
                    }
                ]
            }
        ]
    },
    {
        "id": "sleep-hygiene",
        "title": "Vệ sinh giấc ngủ cơ bản",
        "description": "Những thói quen và thay đổi môi trường đơn giản giúp bạn ngủ ngon hơn.",
        "position": 2,
        "slides": [
            {
                "id": "hygiene-sanctuary",
                "type": "doc",
                "title": "Tạo không gian ngủ lý tưởng",
                "content": "<h3>Tạo không gian ngủ lý tưởng</h3><p>Giữ phòng ngủ <strong>mát mẻ, tối và yên tĩnh</strong>. Hạn chế sử dụng thiết bị điện tử nếu có thể. Giường ngủ nên được liên kết với giấc ngủ, không phải lướt mạng.</p>"
            },
            {
                "id": "hygiene-schedule",
                "type": "doc",
                "title": "Thiết lập lịch ngủ nhất quán",
                "content": "<h3>Thiết lập lịch ngủ nhất quán</h3><p>Đi ngủ và thức dậy vào cùng một giờ mỗi ngày — kể cả cuối tuần. Điều này giúp điều chỉnh đồng hồ sinh học bên trong cơ thể bạn.</p>"
            },
            {
                "id": "hygiene-winddown",
                "type": "doc",
                "title": "Thói quen thư giãn trước khi ngủ",
                "content": "<h3>Thói quen thư giãn trước khi ngủ</h3><p>Bắt đầu thư giãn 30-60 phút trước khi đi ngủ. Giảm ánh sáng, tránh màn hình và làm điều gì đó nhẹ nhàng như đọc sách, duỗi người hoặc viết nhật ký.</p>"
            },
            {
                "id": "hygiene-checklist",
                "type": "checklist_input",
                "question": "Thói quen trước khi ngủ lý tưởng của bạn gồm những gì?",
                "config": { "placeholder": "Thêm một bước vào thói quen của bạn..." }
            },
            {
                "id": "hygiene-change",
                "type": "journal_prompt",
                "question": "Mình có thể thay đổi điều gì để ngủ ngon hơn?",
                "config": { "allowAI": true }
            },
            {
                "id": "hygiene-completion",
                "type": "completion",
                "title": "Thói quen đã được thiết lập!",
                "content": "Những thay đổi nhỏ trong môi trường ngủ có thể tạo ra sự khác biệt lớn.",
                "metric_label": "Đã học vệ sinh giấc ngủ",
                "recommended_next": [
                    {
                        "slide_group_id": "racing-thoughts",
                        "collection_id": "cccc3333-cccc-4333-cccc-cccccccc3333",
                        "title": "Xoa dịu suy nghĩ lộn xộn",
                        "description": "Kỹ thuật làm yên tâm trí trước khi ngủ."
                    },
                    {
                        "slide_group_id": "mindful-breathing",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Thở có ý thức",
                        "description": "Một bài tập thở hoàn hảo cho giờ đi ngủ."
                    }
                ]
            }
        ]
    },
    {
        "id": "racing-thoughts",
        "title": "Xoa dịu suy nghĩ lộn xộn",
        "description": "Kỹ thuật làm yên tâm trí khi những suy nghĩ cứ giữ bạn tỉnh giấc.",
        "position": 3,
        "slides": [
            {
                "id": "racing-dump",
                "type": "doc",
                "title": "Xả hết lo lắng ra ngoài",
                "content": "<h3>Xả hết lo lắng ra ngoài</h3><p>Trước khi đi ngủ, hãy viết ra tất cả những gì đang trong tâm trí bạn. Đưa chúng ra khỏi đầu và lên trang giấy. Bạn có thể giải quyết chúng vào ngày mai — ngay bây giờ, đến lúc nghỉ ngơi rồi.</p>"
            },
            {
                "id": "racing-scan",
                "type": "doc",
                "title": "Thư giãn bằng quét cơ thể",
                "content": "<h3>Thư giãn bằng quét cơ thể</h3><p>Bắt đầu từ ngón chân, từ từ tập trung vào việc thư giãn từng bộ phận của cơ thể. Nhận ra sự căng thẳng và có ý thức giải phóng nó khi bạn di chuyển lên trên.</p>"
            },
            {
                "id": "racing-478",
                "type": "doc",
                "title": "Kỹ thuật thở 4-7-8",
                "content": "<h3>Kỹ thuật thở 4-7-8</h3><p>Hít vào trong 4 nhịp đếm, giữ trong 7 nhịp đếm, thở ra chậm rãi trong 8 nhịp đếm. Kiểu thở này kích hoạt phản ứng thư giãn và giúp làm yên tâm trí.</p>"
            },
            {
                "id": "racing-cta-grounding",
                "type": "cta",
                "title": "Cần thêm công cụ neo đậu tâm trí?",
                "content": "Khám phá các kỹ thuật neo đậu bổ sung cho những lúc suy nghĩ cảm thấy quá tải.",
                "config": {
                    "slide_group_id": "grounding-techniques",
                    "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222"
                }
            },
            {
                "id": "racing-completion",
                "type": "completion",
                "title": "Kỹ thuật nghỉ ngơi đã sẵn sàng",
                "content": "Thử một trong những kỹ thuật này tối nay. Với sự thực hành, chúng sẽ ngày càng hiệu quả hơn.",
                "metric_label": "Đã học kỹ thuật xoa dịu",
                "recommended_next": [
                    {
                        "slide_group_id": "evening-sleep-reflection",
                        "collection_id": "cccc3333-cccc-4333-cccc-cccccccc3333",
                        "title": "Suy ngẫm buổi tối",
                        "description": "Câu hỏi nhật ký để xử lý ngày trước khi ngủ."
                    }
                ]
            }
        ]
    },
    {
        "id": "evening-sleep-reflection",
        "title": "Suy ngẫm buổi tối",
        "description": "Câu hỏi nhật ký giúp bạn xử lý ngày và chuẩn bị cho giấc ngủ ngon.",
        "position": 4,
        "slides": [
            {
                "id": "sleep-tonight-quality",
                "type": "sleep_check",
                "question": "Bạn cảm thấy mệt mỏi thế nào ngay bây giờ?",
                "config": { "min": 0, "max": 100 }
            },
            {
                "id": "sleep-grateful",
                "type": "journal_prompt",
                "question": "Ba điều hôm nay mình cảm thấy biết ơn là gì?",
                "config": { "allowAI": true }
            },
            {
                "id": "sleep-letgo",
                "type": "journal_prompt",
                "question": "Mình có thể buông bỏ điều gì từ hôm nay?",
                "config": { "allowAI": true }
            },
            {
                "id": "sleep-onmind",
                "type": "journal_prompt",
                "question": "Suy nghĩ nào còn vương vấn trong đầu mà mình có thể viết ra để trút bỏ?",
                "config": { "allowAI": true }
            },
            {
                "id": "sleep-tomorrow",
                "type": "journal_prompt",
                "question": "Ngày mai thức dậy mình muốn cảm thấy thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "sleep-day-rating",
                "type": "star_rating",
                "question": "Bạn đánh giá sự nghỉ ngơi của mình hôm nay thế nào?",
                "config": { "min": 1, "max": 5 }
            },
            {
                "id": "sleep-reflection-completion",
                "type": "completion",
                "title": "Sẵn sàng nghỉ ngơi",
                "content": "Bạn đã buông bỏ ngày hôm nay. Chúc bạn ngủ ngon tối nay.",
                "metric_label": "Hoàn tất tất cả bài học Ngủ ngon hơn",
                "recommended_next": [
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Biết ơn hàng ngày",
                        "description": "Luyện tập lòng biết ơn để nâng cao sức khỏe tổng thể."
                    },
                    {
                        "slide_group_id": "evening-reflection",
                        "collection_id": "55555555-5555-5555-5555-555555555555",
                        "title": "Suy ngẫm buổi tối",
                        "description": "Thực hành viết nhật ký tổng quát vào buổi tối."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'cccc3333-cccc-4333-cccc-cccccccc3333';