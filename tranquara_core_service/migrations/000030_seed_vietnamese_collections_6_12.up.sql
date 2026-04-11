-- Migration 000030: Vietnamese translations for Collections 6-12
-- Continues from 000029 which deferred these collections
-- Covers: Better Sleep, Relationships, Gratitude, Understanding Emotions,
--          Mindfulness, Self-Compassion, Check-Ins

-- ============================================================================
-- Collection 6: Better Sleep (cccc3333-cccc-4333-cccc-cccccccc3333) — learn
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
                "config": {
                    "min": 0,
                    "max": 100
                }
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
                "question": "Thói quen trước khi ngủ lý tưởng của bạn trông như thế nào?",
                "config": {
                    "placeholder": "Thêm một bước vào thói quen của bạn..."
                }
            },
            {
                "id": "hygiene-change",
                "type": "journal_prompt",
                "question": "Một thay đổi nào tôi có thể thực hiện để cải thiện môi trường ngủ của mình?",
                "config": {
                    "allowAI": true
                }
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
                "config": {
                    "min": 0,
                    "max": 100
                }
            },
            {
                "id": "sleep-grateful",
                "type": "journal_prompt",
                "question": "Ba điều tôi biết ơn từ ngày hôm nay là gì?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "sleep-letgo",
                "type": "journal_prompt",
                "question": "Điều gì tôi có thể buông bỏ từ ngày hôm nay?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "sleep-onmind",
                "type": "journal_prompt",
                "question": "Những suy nghĩ nào vẫn còn trong tâm trí tôi mà tôi có thể viết ra và giải phóng?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "sleep-tomorrow",
                "type": "journal_prompt",
                "question": "Tôi muốn cảm thấy thế nào khi thức dậy vào ngày mai?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "sleep-day-rating",
                "type": "star_rating",
                "question": "Bạn đánh giá sự nghỉ ngơi của mình hôm nay thế nào?",
                "config": {
                    "min": 1,
                    "max": 5
                }
            },
            {
                "id": "sleep-reflection-completion",
                "type": "completion",
                "title": "Sẵn sàng nghỉ ngơi",
                "content": "Bạn đã buông bỏ ngày hôm nay. Chúc bạn ngủ ngon tối nay.",
                "metric_label": "Hoàn tất tất cả bài học Giấc ngủ tốt hơn",
                "recommended_next": [
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Biết ơn hàng ngày",
                        "description": "Thực hành biết ơn để nâng cao sức khỏe tổng thể."
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


-- ============================================================================
-- Collection 7: Relationships & Connection (dddd4444-...) — journal
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "relationship-reflection",
        "title": "Suy ngẫm về mối quan hệ",
        "description": "Suy ngẫm về chất lượng và các mẫu hình trong những mối quan hệ thân thiết nhất của bạn.",
        "position": 1,
        "slides": [
            {
                "id": "rel-important",
                "type": "journal_prompt",
                "question": "Những người quan trọng nhất trong cuộc sống của tôi hiện tại là ai?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-show-love",
                "type": "journal_prompt",
                "question": "Tôi thể hiện tình yêu và sự trân trọng với những người thân thiết như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-nourish-drain",
                "type": "journal_prompt",
                "question": "Những mối quan hệ nào cảm thấy nuôi dưỡng, và mối quan hệ nào cảm thấy tiêu hao năng lượng?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-neglect",
                "type": "journal_prompt",
                "question": "Có mối quan hệ nào tôi đã sao nhãng mà muốn vun đắp lại không?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-reflection-completion",
                "type": "completion",
                "title": "Suy ngẫm hoàn tất",
                "content": "Nhận thức về các mẫu hình trong mối quan hệ là bước quan trọng để xây dựng sự kết nối sâu sắc hơn.",
                "recommended_next": [
                    {
                        "slide_group_id": "communication-patterns",
                        "collection_id": "dddd4444-dddd-4444-dddd-dddddddd4444",
                        "title": "Mẫu giao tiếp",
                        "description": "Khám phá cách bạn giao tiếp và tác động của nó."
                    },
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Hiểu về cảm xúc",
                        "description": "Nâng cao nhận thức cảm xúc để cải thiện các mối quan hệ."
                    }
                ]
            }
        ]
    },
    {
        "id": "communication-patterns",
        "title": "Mẫu giao tiếp",
        "description": "Khám phá cách bạn giao tiếp và nó ảnh hưởng đến các mối quan hệ như thế nào.",
        "position": 2,
        "slides": [
            {
                "id": "comm-express",
                "type": "journal_prompt",
                "question": "Tôi thường bày tỏ nhu cầu và cảm xúc của mình với người khác như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "comm-misunderstood",
                "type": "journal_prompt",
                "question": "Điều gì xảy ra khi tôi cảm thấy bị hiểu lầm hoặc không được lắng nghe?",
                "config": { "allowAI": true }
            },
            {
                "id": "comm-struggle",
                "type": "journal_prompt",
                "question": "Có những điều tôi khó nói với những người thân thiết không?",
                "config": { "allowAI": true }
            },
            {
                "id": "comm-conflict",
                "type": "journal_prompt",
                "question": "Tôi xử lý mâu thuẫn trong các mối quan hệ như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "comm-completion",
                "type": "completion",
                "title": "Đã nhận ra các mẫu hình",
                "content": "Hiểu cách bạn giao tiếp là bước đầu tiên để xây dựng những kết nối lành mạnh hơn.",
                "recommended_next": [
                    {
                        "slide_group_id": "setting-boundaries",
                        "collection_id": "dddd4444-dddd-4444-dddd-dddddddd4444",
                        "title": "Thiết lập ranh giới",
                        "description": "Suy ngẫm về ranh giới của bạn và cách chúng bảo vệ bạn."
                    }
                ]
            }
        ]
    },
    {
        "id": "setting-boundaries",
        "title": "Thiết lập ranh giới",
        "description": "Suy ngẫm về ranh giới của bạn và cách chúng bảo vệ sức khỏe của bạn.",
        "position": 3,
        "slides": [
            {
                "id": "bound-need",
                "type": "journal_prompt",
                "question": "Tôi cần thiết lập hoặc củng cố ranh giới nào trong cuộc sống?",
                "config": { "allowAI": true }
            },
            {
                "id": "bound-crossed",
                "type": "journal_prompt",
                "question": "Tôi cảm thấy thế nào khi ranh giới của mình bị xâm phạm?",
                "config": { "allowAI": true }
            },
            {
                "id": "bound-no",
                "type": "journal_prompt",
                "question": "Điều gì khiến tôi khó nói không?",
                "config": { "allowAI": true }
            },
            {
                "id": "bound-communicate",
                "type": "journal_prompt",
                "question": "Tôi có thể truyền đạt ranh giới của mình với sự tử tế và rõ ràng như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "bound-completion",
                "type": "completion",
                "title": "Ranh giới đã được khám phá",
                "content": "Ranh giới lành mạnh là hành động yêu thương bản thân và tôn trọng — cả với bạn và người khác.",
                "recommended_next": [
                    {
                        "slide_group_id": "forgiveness-letting-go",
                        "collection_id": "dddd4444-dddd-4444-dddd-dddddddd4444",
                        "title": "Tha thứ & Buông bỏ",
                        "description": "Khám phá sự tha thứ như con đường đến tự do."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Tự thương yêu bản thân",
                        "description": "Hãy tử tế với bản thân qua những thách thức trong mối quan hệ."
                    }
                ]
            }
        ]
    },
    {
        "id": "forgiveness-letting-go",
        "title": "Tha thứ & Buông bỏ",
        "description": "Khám phá sự tha thứ — cả cho đi và nhận lại.",
        "position": 4,
        "slides": [
            {
                "id": "forgive-resentment",
                "type": "journal_prompt",
                "question": "Có ai đó mà tôi đang giữ oán giận không? Chuyện gì đã xảy ra?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-affect",
                "type": "journal_prompt",
                "question": "Việc giữ điều này ảnh hưởng đến tôi như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-mean",
                "type": "journal_prompt",
                "question": "Tha thứ có nghĩa là gì — và tôi cần buông bỏ điều gì?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-self",
                "type": "journal_prompt",
                "question": "Có điều gì tôi cần tha thứ cho chính mình không?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-completion",
                "type": "completion",
                "title": "Một gánh nặng được nhấc lên",
                "content": "Tha thứ không có nghĩa là chấp nhận hành vi sai — mà là giải phóng bản thân để tiến về phía trước.",
                "metric_label": "Hoàn tất bộ sưu tập Mối quan hệ",
                "recommended_next": [
                    {
                        "slide_group_id": "self-forgiveness",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Tự tha thứ",
                        "description": "Đi sâu hơn vào việc tha thứ cho bản thân."
                    },
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Biết ơn hàng ngày",
                        "description": "Chuyển sự chú ý sang sự trân trọng và tích cực."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'dddd4444-dddd-4444-dddd-dddddddd4444';


-- ============================================================================
-- Collection 8: Gratitude Practice (eeee5555-...) — journal
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "daily-gratitude",
        "title": "Biết ơn hàng ngày",
        "description": "Thực hành hàng ngày đơn giản để nhận ra và trân trọng những điều tốt đẹp trong cuộc sống.",
        "position": 1,
        "slides": [
            {
                "id": "grat-three",
                "type": "journal_prompt",
                "question": "Ba điều tôi biết ơn hôm nay là gì?",
                "config": { "allowAI": true }
            },
            {
                "id": "grat-small",
                "type": "journal_prompt",
                "question": "Khoảnh khắc nhỏ nào mang lại cho tôi niềm vui hoặc sự bình yên hôm nay?",
                "config": { "allowAI": true }
            },
            {
                "id": "grat-person",
                "type": "journal_prompt",
                "question": "Ai đã tạo ra sự khác biệt tích cực trong ngày của tôi, và như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "grat-completion",
                "type": "completion",
                "title": "Lòng biết ơn đã được ghi nhận!",
                "content": "Dành thời gian trân trọng những điều tốt đẹp trong cuộc sống sẽ thay đổi góc nhìn của bạn theo thời gian.",
                "recommended_next": [
                    {
                        "slide_group_id": "appreciating-self",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Trân trọng bản thân",
                        "description": "Hướng lòng biết ơn vào trong và trân trọng những phẩm chất của bạn."
                    },
                    {
                        "slide_group_id": "evening-reflection",
                        "collection_id": "55555555-5555-5555-5555-555555555555",
                        "title": "Suy ngẫm buổi tối",
                        "description": "Tiếp tục suy ngẫm về ngày của bạn."
                    }
                ]
            }
        ]
    },
    {
        "id": "appreciating-self",
        "title": "Trân trọng bản thân",
        "description": "Hướng lòng biết ơn vào trong và trân trọng những phẩm chất và nỗ lực của bạn.",
        "position": 2,
        "slides": [
            {
                "id": "self-appreciate",
                "type": "journal_prompt",
                "question": "Điều gì tôi trân trọng về bản thân hôm nay?",
                "config": { "allowAI": true }
            },
            {
                "id": "self-challenge",
                "type": "journal_prompt",
                "question": "Thách thức nào tôi đã xử lý tốt gần đây?",
                "config": { "allowAI": true }
            },
            {
                "id": "self-strength",
                "type": "journal_prompt",
                "question": "Điểm mạnh nào đã giúp tôi vượt qua một khoảnh khắc khó khăn?",
                "config": { "allowAI": true }
            },
            {
                "id": "self-growth",
                "type": "journal_prompt",
                "question": "Tôi đã trưởng thành như thế nào trong năm vừa qua?",
                "config": { "allowAI": true }
            },
            {
                "id": "self-appreciate-completion",
                "type": "completion",
                "title": "Bạn xứng đáng được trân trọng",
                "content": "Nhận ra những điểm mạnh của bản thân xây dựng sức kiên cường và sự tự tin.",
                "recommended_next": [
                    {
                        "slide_group_id": "appreciating-others",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Trân trọng người khác",
                        "description": "Suy ngẫm về những người làm phong phú cuộc sống của bạn."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Tự thương yêu bản thân",
                        "description": "Đào sâu sự trân trọng bản thân với lòng tự trắc ẩn."
                    }
                ]
            }
        ]
    },
    {
        "id": "appreciating-others",
        "title": "Trân trọng người khác",
        "description": "Suy ngẫm về những người làm phong phú cuộc sống của bạn và cân nhắc bày tỏ sự trân trọng.",
        "position": 3,
        "slides": [
            {
                "id": "others-granted",
                "type": "journal_prompt",
                "question": "Ai là người tôi thường coi là đương nhiên nhưng thực sự biết ơn?",
                "config": { "allowAI": true }
            },
            {
                "id": "others-done",
                "type": "journal_prompt",
                "question": "Gần đây ai đó đã làm gì cho tôi mà tôi trân trọng?",
                "config": { "allowAI": true }
            },
            {
                "id": "others-express",
                "type": "journal_prompt",
                "question": "Tôi có thể bày tỏ lòng biết ơn của mình với ai đó trong tuần này như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "others-qualities",
                "type": "journal_prompt",
                "question": "Tôi ngưỡng mộ những phẩm chất nào ở những người thân thiết nhất với tôi?",
                "config": { "allowAI": true }
            },
            {
                "id": "others-cta-relationships",
                "type": "cta",
                "title": "Muốn củng cố các kết nối của bạn?",
                "content": "Khám phá cách các mối quan hệ của bạn định hình sức khỏe tinh thần.",
                "config": {
                    "slide_group_id": "relationship-reflection",
                    "collection_id": "dddd4444-dddd-4444-dddd-dddddddd4444"
                }
            },
            {
                "id": "others-completion",
                "type": "completion",
                "title": "Sự trân trọng đã được chia sẻ",
                "content": "Lòng biết ơn dành cho người khác củng cố các mối quan hệ và mang lại niềm vui cho cả hai.",
                "recommended_next": [
                    {
                        "slide_group_id": "silver-linings",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Tìm điểm sáng",
                        "description": "Thực hành lòng biết ơn ngay cả trong những tình huống khó khăn."
                    }
                ]
            }
        ]
    },
    {
        "id": "silver-linings",
        "title": "Tìm điểm sáng",
        "description": "Thực hành tìm kiếm lòng biết ơn ngay cả trong những tình huống khó khăn.",
        "position": 4,
        "slides": [
            {
                "id": "silver-difficult",
                "type": "journal_prompt",
                "question": "Trải nghiệm khó khăn nào đã dạy cho tôi điều gì có giá trị?",
                "config": { "allowAI": true }
            },
            {
                "id": "silver-positive",
                "type": "journal_prompt",
                "question": "Có điều gì tích cực nảy sinh từ một tình huống thách thức không?",
                "config": { "allowAI": true }
            },
            {
                "id": "silver-grow",
                "type": "journal_prompt",
                "question": "Một khó khăn đã giúp tôi trưởng thành hoặc trở nên mạnh mẽ hơn như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "silver-learning",
                "type": "journal_prompt",
                "question": "Tôi đang học được gì từ những thách thức hiện tại?",
                "config": { "allowAI": true }
            },
            {
                "id": "silver-completion",
                "type": "completion",
                "title": "Góc nhìn đã thay đổi",
                "content": "Tìm thấy lòng biết ơn trong khó khăn là một kỹ năng kiên cường mạnh mẽ. Thật xuất sắc.",
                "metric_label": "Hoàn tất bộ sưu tập Thực hành biết ơn",
                "recommended_next": [
                    {
                        "slide_group_id": "what-is-mindfulness",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Chánh niệm",
                        "description": "Nuôi dưỡng nhận thức khoảnh khắc hiện tại và sự bình yên."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Tự thương yêu bản thân",
                        "description": "Hãy tử tế với bản thân qua những thách thức."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'eeee5555-eeee-4555-eeee-eeeeeeee5555';


-- ============================================================================
-- Collection 9: Understanding Emotions (ffff6666-...) — learn
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "what-are-emotions",
        "title": "Cảm xúc là gì?",
        "description": "Hiểu cảm xúc như những thông điệp hơn là vấn đề cần giải quyết.",
        "position": 1,
        "slides": [
            {
                "id": "emo-messengers",
                "type": "doc",
                "title": "Cảm xúc là những thông điệp",
                "content": "<h3>Cảm xúc là những thông điệp</h3><p>Cảm xúc không tốt hay xấu — chúng là <strong>thông tin</strong>. Chúng cho chúng ta biết về nhu cầu, ranh giới và những gì quan trọng với chúng ta. Học cách lắng nghe chúng là chìa khóa để có sức khỏe cảm xúc.</p>"
            },
            {
                "id": "emo-purpose",
                "type": "doc",
                "title": "Mục đích của cảm xúc",
                "content": "<h3>Mục đích của cảm xúc</h3><p><strong>Sợ hãi</strong> bảo vệ chúng ta khỏi nguy hiểm. <strong>Tức giận</strong> báo hiệu ranh giới đã bị vi phạm. <strong>Buồn bã</strong> giúp chúng ta xử lý mất mát. <strong>Vui mừng</strong> kết nối chúng ta với điều chúng ta yêu thích. Mỗi cảm xúc đều có mục đích.</p>"
            },
            {
                "id": "emo-temporary",
                "type": "doc",
                "title": "Cảm xúc là tạm thời",
                "content": "<h3>Cảm xúc là tạm thời</h3><p>Không có cảm xúc nào kéo dài mãi mãi. Như những con sóng, chúng dâng lên, đạt đỉnh và lắng xuống. Cưỡng lại chúng thường làm chúng mạnh hơn; chấp nhận chúng giúp chúng qua đi.</p>"
            },
            {
                "id": "emo-identify",
                "type": "questionnaire",
                "question": "Cảm xúc nào đang hiện diện nhiều nhất trong bạn lúc này?",
                "content": "Chọn cái phù hợp nhất với bạn trong khoảnh khắc này.",
                "mode": "single",
                "options": [
                    {"id": "joy", "label": "Vui mừng hoặc bằng lòng", "description": "Tôi cảm thấy tốt, biết ơn hoặc bình yên"},
                    {"id": "sadness", "label": "Buồn bã", "description": "Tôi cảm thấy nặng nề, thấp thỏm hoặc đau buồn"},
                    {"id": "anxiety", "label": "Lo âu hoặc lo lắng", "description": "Tôi cảm thấy căng thẳng, bất an hoặc sợ hãi"},
                    {"id": "anger", "label": "Tức giận hoặc thất vọng", "description": "Tôi cảm thấy bực bội, khó chịu hoặc oán giận"},
                    {"id": "numb", "label": "Tê liệt hoặc xa cách", "description": "Tôi không cảm thấy gì nhiều"},
                    {"id": "confused", "label": "Bối rối", "description": "Tôi không chắc mình đang cảm thấy gì"}
                ]
            },
            {
                "id": "emo-what-completion",
                "type": "completion",
                "title": "Đã hiểu về cảm xúc",
                "content": "Mọi cảm xúc đều hợp lệ và tạm thời. Bạn càng lắng nghe, bạn càng hiểu bản thân hơn.",
                "metric_label": "Hoàn tất bài học",
                "recommended_next": [
                    {
                        "slide_group_id": "emotional-awareness",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Xây dựng nhận thức cảm xúc",
                        "description": "Học cách nhận ra và đặt tên cho cảm xúc một cách chính xác hơn."
                    }
                ]
            }
        ]
    },
    {
        "id": "emotional-awareness",
        "title": "Xây dựng nhận thức cảm xúc",
        "description": "Học cách nhận ra và đặt tên cho cảm xúc của bạn với độ chính xác cao hơn.",
        "position": 2,
        "slides": [
            {
                "id": "aware-name",
                "type": "doc",
                "title": "Đặt tên để thuần hóa",
                "content": "<h3>Đặt tên để thuần hóa</h3><p>Nghiên cứu cho thấy chỉ đơn giản là <strong>đặt tên một cảm xúc</strong> có thể giảm cường độ của nó. Thay vì 'Tôi cảm thấy tệ,' hãy cố gắng cụ thể hơn: 'Tôi cảm thấy thất vọng và hơi lo lắng.'</p>"
            },
            {
                "id": "aware-body",
                "type": "doc",
                "title": "Cảm xúc trong cơ thể",
                "content": "<h3>Cảm xúc trong cơ thể</h3><p>Cảm xúc biểu hiện ra thể chất. Lo âu có thể cảm thấy như ngực thắt chặt. Buồn bã có thể cảm thấy nặng nề. Tức giận có thể cảm thấy nóng ran. Hãy chú ý nơi bạn cảm thấy cảm xúc trong cơ thể.</p>"
            },
            {
                "id": "aware-current",
                "type": "journal_prompt",
                "question": "Tôi đang cảm thấy cảm xúc gì ngay bây giờ? Tôi cảm nhận nó ở đâu trong cơ thể?",
                "config": { "allowAI": true }
            },
            {
                "id": "aware-telling",
                "type": "journal_prompt",
                "question": "Cảm xúc này đang cố nói với tôi điều gì?",
                "config": { "allowAI": true }
            },
            {
                "id": "aware-completion",
                "type": "completion",
                "title": "Nhận thức đã được sâu sắc hơn",
                "content": "Đặt tên cho cảm xúc một cách chính xác là một kỹ năng phát triển qua thực hành.",
                "recommended_next": [
                    {
                        "slide_group_id": "difficult-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Làm việc với cảm xúc khó",
                        "description": "Chiến lược để chịu đựng những cảm giác không thoải mái."
                    }
                ]
            }
        ]
    },
    {
        "id": "difficult-emotions",
        "title": "Làm việc với cảm xúc khó",
        "description": "Chiến lược để chịu đựng những cảm xúc không thoải mái mà không bị áp đảo.",
        "position": 3,
        "slides": [
            {
                "id": "diff-dont-fight",
                "type": "doc",
                "title": "Đừng chống lại, đừng chạy theo",
                "content": "<h3>Đừng chống lại, đừng chạy theo</h3><p>Khi một cảm xúc khó khăn xuất hiện, đừng cố đẩy nó đi (chống lại) hoặc bị cuốn vào câu chuyện (chạy theo). Thay vào đó, hãy <strong>thừa nhận nó</strong>: 'Tôi nhận thấy mình đang cảm thấy lo âu ngay lúc này.'</p>"
            },
            {
                "id": "diff-rain",
                "type": "doc",
                "title": "Kỹ thuật RAIN",
                "content": "<h3>Kỹ thuật RAIN</h3><p><strong>R</strong>ecognize — Nhận ra những gì đang xảy ra. <strong>A</strong>llow — Cho phép trải nghiệm hiện diện. <strong>I</strong>nvestigate — Điều tra với sự tử tế. <strong>N</strong>urture — Nuôi dưỡng bản thân với lòng tự trắc ẩn.</p>"
            },
            {
                "id": "diff-avoiding",
                "type": "journal_prompt",
                "question": "Cảm xúc khó khăn nào tôi đã tránh né gần đây?",
                "config": { "allowAI": true }
            },
            {
                "id": "diff-support",
                "type": "journal_prompt",
                "question": "Tôi cần gì ngay bây giờ để hỗ trợ bản thân qua cảm giác này?",
                "config": { "allowAI": true }
            },
            {
                "id": "diff-completion",
                "type": "completion",
                "title": "Sự dũng cảm được ghi nhận",
                "content": "Đối mặt với cảm xúc khó khăn đòi hỏi sự dũng cảm. Bạn đang xây dựng sức kiên cường cảm xúc.",
                "recommended_next": [
                    {
                        "slide_group_id": "emotional-triggers",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Hiểu về tác nhân kích hoạt",
                        "description": "Khám phá điều gì kích hoạt những phản ứng cảm xúc mạnh mẽ."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Tự thương yêu bản thân",
                        "description": "Hãy tử tế với bản thân qua những cơn bão cảm xúc."
                    }
                ]
            }
        ]
    },
    {
        "id": "emotional-triggers",
        "title": "Hiểu về tác nhân kích hoạt",
        "description": "Khám phá điều gì kích hoạt những phản ứng cảm xúc mạnh mẽ và tại sao.",
        "position": 4,
        "slides": [
            {
                "id": "trigger-what",
                "type": "doc",
                "title": "Tác nhân cảm xúc là gì?",
                "content": "<h3>Tác nhân cảm xúc là gì?</h3><p>Tác nhân kích hoạt là thứ gây ra phản ứng cảm xúc mạnh mẽ — thường liên quan đến những trải nghiệm trong quá khứ. Hiểu tác nhân kích hoạt của bạn giúp bạn phản ứng thay vì phản xạ.</p>"
            },
            {
                "id": "trigger-situations",
                "type": "journal_prompt",
                "question": "Những tình huống nào thường kích hoạt cảm xúc mạnh trong tôi?",
                "config": { "allowAI": true }
            },
            {
                "id": "trigger-react",
                "type": "journal_prompt",
                "question": "Khi bị kích hoạt, tôi thường phản ứng như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "trigger-past",
                "type": "journal_prompt",
                "question": "Trải nghiệm nào trong quá khứ có thể liên quan đến tác nhân kích hoạt này?",
                "config": { "allowAI": true }
            },
            {
                "id": "trigger-respond",
                "type": "journal_prompt",
                "question": "Tôi có thể phản ứng khác đi thế nào lần sau khi bị kích hoạt?",
                "config": { "allowAI": true }
            },
            {
                "id": "trigger-completion",
                "type": "completion",
                "title": "Kiến thức về bản thân đã được tích lũy",
                "content": "Hiểu tác nhân kích hoạt của bạn là bước mạnh mẽ hướng đến sự tự do cảm xúc.",
                "metric_label": "Hoàn tất Hiểu về cảm xúc",
                "recommended_next": [
                    {
                        "slide_group_id": "what-is-mindfulness",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Chánh niệm",
                        "description": "Học cách quan sát cảm xúc mà không phản xạ."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Tự thương yêu bản thân",
                        "description": "Gặp gỡ bản thân với sự tử tế qua những cơn bão cảm xúc."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'ffff6666-ffff-4666-ffff-ffffffff6666';


-- ============================================================================
-- Collection 10: Mindfulness (a0a07777-...) — learn
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "what-is-mindfulness",
        "title": "Chánh niệm là gì?",
        "description": "Hiểu về chánh niệm và tại sao nó quan trọng đối với sức khỏe tinh thần.",
        "position": 1,
        "slides": [
            {
                "id": "mind-defined",
                "type": "doc",
                "title": "Định nghĩa chánh niệm",
                "content": "<h3>Định nghĩa chánh niệm</h3><p>Chánh niệm là <strong>chú ý đến khoảnh khắc hiện tại, có chủ đích, không phán xét</strong>. Đó là việc nhận thức những gì đang xảy ra ngay bây giờ — suy nghĩ, cảm xúc và cảm giác — với sự tò mò thay vì chỉ trích.</p>"
            },
            {
                "id": "mind-why",
                "type": "doc",
                "title": "Tại sao chánh niệm giúp ích",
                "content": "<h3>Tại sao chánh niệm giúp ích</h3><p>Khi chúng ta bị cuốn vào lo lắng về tương lai hoặc hối tiếc về quá khứ, chúng ta đau khổ. Chánh niệm đưa chúng ta trở lại khoảnh khắc duy nhất mà chúng ta thực sự có thể sống — <strong>hiện tại</strong>.</p>"
            },
            {
                "id": "mind-skill",
                "type": "doc",
                "title": "Chánh niệm là một kỹ năng",
                "content": "<h3>Chánh niệm là một kỹ năng</h3><p>Như bất kỳ kỹ năng nào, chánh niệm được cải thiện qua thực hành. Bạn không cần phải hoàn hảo. Mục tiêu không phải là làm trống tâm trí — mà là nhận thấy khi tâm trí lang thang và nhẹ nhàng đưa nó trở lại.</p>"
            },
            {
                "id": "mind-experience-check",
                "type": "questionnaire",
                "question": "Kinh nghiệm của bạn với chánh niệm là gì?",
                "content": "Điều này giúp chúng tôi hiểu bạn đang bắt đầu từ đâu.",
                "mode": "single",
                "options": [
                    {"id": "new", "label": "Hoàn toàn mới", "description": "Tôi chưa bao giờ thử chánh niệm trước đây"},
                    {"id": "curious", "label": "Người mới tò mò", "description": "Tôi đã nghe về nó nhưng hiếm khi thực hành"},
                    {"id": "occasional", "label": "Thực hành thỉnh thoảng", "description": "Đôi khi tôi cố gắng có ý thức hơn"},
                    {"id": "regular", "label": "Thực hành thường xuyên", "description": "Tôi thực hành chánh niệm thường xuyên"}
                ]
            },
            {
                "id": "mind-what-completion",
                "type": "completion",
                "title": "Hành trình đã bắt đầu",
                "content": "Dù bạn bắt đầu từ đâu, chánh niệm đều có thể mang lại lợi ích cho bạn.",
                "metric_label": "Hoàn tất bài học",
                "recommended_next": [
                    {
                        "slide_group_id": "mindful-breathing",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Thở có ý thức",
                        "description": "Một bài tập đơn giản dùng hơi thở làm điểm neo."
                    }
                ]
            }
        ]
    },
    {
        "id": "mindful-breathing",
        "title": "Thở có ý thức",
        "description": "Một bài tập đơn giản dùng hơi thở làm điểm neo vào khoảnh khắc hiện tại.",
        "position": 2,
        "slides": [
            {
                "id": "breath-anchor",
                "type": "doc",
                "title": "Hơi thở luôn hiện diện cùng bạn",
                "content": "<h3>Hơi thở luôn hiện diện cùng bạn</h3><p>Hơi thở là điểm neo mạnh mẽ vào hiện tại. Nó luôn xảy ra ngay bây giờ, làm cho nó trở thành sự tập trung hoàn hảo cho việc thực hành chánh niệm.</p>"
            },
            {
                "id": "breath-how",
                "type": "doc",
                "title": "Cách thực hành",
                "content": "<h3>Cách thực hành</h3><p>Ngồi thoải mái và nhắm mắt lại. Chú ý đến hơi thở — lần hít vào, lần thở ra, khoảng dừng giữa. Khi suy nghĩ xuất hiện, hãy thừa nhận chúng và nhẹ nhàng quay trở lại hơi thở.</p>"
            },
            {
                "id": "breath-small",
                "type": "doc",
                "title": "Bắt đầu nhỏ",
                "content": "<h3>Bắt đầu nhỏ</h3><p>Ngay cả 1-2 phút thở có ý thức cũng có thể tạo ra sự khác biệt. Bắt đầu nhỏ và dần dần tăng lên. Tính nhất quán quan trọng hơn thời lượng.</p>"
            },
            {
                "id": "breath-completion",
                "type": "completion",
                "title": "Điểm neo hơi thở đã sẵn sàng",
                "content": "Bạn giờ có một công cụ có thể dùng bất cứ lúc nào, bất cứ nơi đâu. Chỉ cần thở.",
                "recommended_next": [
                    {
                        "slide_group_id": "body-scan",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Thực hành quét cơ thể",
                        "description": "Kết nối với cảm giác thể chất và giải phóng sự căng thẳng."
                    }
                ]
            }
        ]
    },
    {
        "id": "body-scan",
        "title": "Thực hành quét cơ thể",
        "description": "Bài tập hướng dẫn để kết nối với cảm giác thể chất và giải phóng sự căng thẳng.",
        "position": 3,
        "slides": [
            {
                "id": "scan-what",
                "type": "doc",
                "title": "Quét cơ thể là gì?",
                "content": "<h3>Quét cơ thể là gì?</h3><p>Quét cơ thể là bài tập chánh niệm mà bạn từ từ di chuyển sự chú ý qua các bộ phận khác nhau của cơ thể, nhận thấy các cảm giác mà không cố gắng thay đổi chúng.</p>"
            },
            {
                "id": "scan-how",
                "type": "doc",
                "title": "Cách thực hành",
                "content": "<h3>Cách thực hành</h3><p>Nằm xuống hoặc ngồi thoải mái. Bắt đầu từ đỉnh đầu và từ từ di chuyển sự chú ý xuống qua cơ thể — mặt, cổ, vai, cánh tay, ngực, bụng, chân, bàn chân. Chú ý những gì bạn cảm nhận.</p>"
            },
            {
                "id": "scan-benefits",
                "type": "doc",
                "title": "Lợi ích của quét cơ thể",
                "content": "<h3>Lợi ích của quét cơ thể</h3><p>Quét cơ thể giúp bạn nhận ra nơi bạn đang giữ căng thẳng, kết nối lại với cơ thể và làm dịu hệ thần kinh. Chúng đặc biệt hữu ích trước khi ngủ hoặc trong những lúc căng thẳng.</p>"
            },
            {
                "id": "scan-cta-anxiety",
                "type": "cta",
                "title": "Dùng quét cơ thể cho lo âu?",
                "content": "Tìm hiểu thêm các kỹ thuật neo đậu dành riêng cho những lúc lo âu.",
                "config": {
                    "slide_group_id": "grounding-techniques",
                    "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222"
                }
            },
            {
                "id": "scan-completion",
                "type": "completion",
                "title": "Nhận thức cơ thể đã được nâng cao",
                "content": "Thực hành quét cơ thể thường xuyên giúp bạn duy trì kết nối với trải nghiệm thể chất.",
                "recommended_next": [
                    {
                        "slide_group_id": "mindful-moments",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Khoảnh khắc chánh niệm",
                        "description": "Thực hành chánh niệm qua viết nhật ký suy ngẫm."
                    }
                ]
            }
        ]
    },
    {
        "id": "mindful-moments",
        "title": "Khoảnh khắc chánh niệm",
        "description": "Câu hỏi nhật ký để thực hành chánh niệm qua sự suy ngẫm.",
        "position": 4,
        "slides": [
            {
                "id": "moment-notice",
                "type": "journal_prompt",
                "question": "Tôi đang nhận thấy gì ngay lúc này — suy nghĩ, cảm xúc, cảm giác?",
                "config": { "allowAI": true }
            },
            {
                "id": "moment-sounds",
                "type": "journal_prompt",
                "question": "Tôi có thể nghe thấy những âm thanh gì trong khoảnh khắc này?",
                "config": { "allowAI": true }
            },
            {
                "id": "moment-tension",
                "type": "journal_prompt",
                "question": "Tôi cảm thấy căng thẳng ở đâu trong cơ thể, và tôi có thể buông lỏng xung quanh đó không?",
                "config": { "allowAI": true }
            },
            {
                "id": "moment-appreciate",
                "type": "journal_prompt",
                "question": "Có một điều gì tôi có thể trân trọng về khoảnh khắc hiện tại này không?",
                "config": { "allowAI": true }
            },
            {
                "id": "moment-rating",
                "type": "star_rating",
                "question": "Bạn cảm thấy mức độ hiện diện của mình trong bài tập này như thế nào?",
                "config": {
                    "min": 1,
                    "max": 5
                }
            },
            {
                "id": "moment-completion",
                "type": "completion",
                "title": "Khoảnh khắc hiện tại đã được sống",
                "content": "Mỗi khoảnh khắc chánh niệm củng cố khả năng duy trì sự hiện diện của bạn.",
                "metric_label": "Hoàn tất bộ sưu tập Chánh niệm",
                "recommended_next": [
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Hiểu về cảm xúc",
                        "description": "Kết hợp chánh niệm với nhận thức cảm xúc."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Tự thương yêu bản thân",
                        "description": "Thêm lòng trắc ẩn vào thực hành chánh niệm."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'a0a07777-a0a0-4777-a0a0-a0a0a0a07777';


-- ============================================================================
-- Collection 11: Self-Compassion (b0b08888-...) — learn
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "what-is-self-compassion",
        "title": "Tự thương yêu bản thân là gì?",
        "description": "Hiểu về tự thương yêu bản thân và tại sao nó khác với lòng tự trọng.",
        "position": 1,
        "slides": [
            {
                "id": "comp-defined",
                "type": "doc",
                "title": "Định nghĩa tự thương yêu bản thân",
                "content": "<h3>Định nghĩa tự thương yêu bản thân</h3><p>Tự thương yêu bản thân có nghĩa là đối xử với bản thân bằng sự <strong>tử tế, thấu hiểu và kiên nhẫn</strong> giống như bạn dành cho một người bạn tốt đang gặp khó khăn.</p>"
            },
            {
                "id": "comp-elements",
                "type": "doc",
                "title": "Ba yếu tố của tự thương yêu bản thân",
                "content": "<h3>Ba yếu tố của tự thương yêu bản thân</h3><p><strong>1. Tự tử tế</strong> thay vì tự phán xét. <strong>2. Nhân loại chung</strong> — nhận ra rằng đau khổ là một phần của con người. <strong>3. Chánh niệm</strong> — giữ những cảm xúc đau đớn trong nhận thức cân bằng.</p>"
            },
            {
                "id": "comp-vs-esteem",
                "type": "doc",
                "title": "Tự thương yêu bản thân vs. lòng tự trọng",
                "content": "<h3>Tự thương yêu bản thân vs. lòng tự trọng</h3><p>Lòng tự trọng là đánh giá bản thân một cách tích cực. Tự thương yêu bản thân là <strong>tử tế với bản thân bất kể thành công hay thất bại</strong>. Nó ổn định và vô điều kiện hơn.</p>"
            },
            {
                "id": "comp-what-completion",
                "type": "completion",
                "title": "Sự tử tế bắt đầu từ bên trong",
                "content": "Hiểu về tự thương yêu bản thân mở ra cánh cửa để có mối quan hệ nhẹ nhàng hơn với bản thân.",
                "metric_label": "Hoàn tất bài học",
                "recommended_next": [
                    {
                        "slide_group_id": "inner-critic",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Làm việc với giọng nói phê bình nội tâm",
                        "description": "Học cách nhận ra và làm dịu giọng nói nội tâm khắc nghiệt."
                    }
                ]
            }
        ]
    },
    {
        "id": "inner-critic",
        "title": "Làm việc với giọng nói phê bình nội tâm",
        "description": "Học cách nhận ra và làm dịu giọng nói nội tâm khắc nghiệt của bạn.",
        "position": 2,
        "slides": [
            {
                "id": "critic-what",
                "type": "doc",
                "title": "Giọng nói phê bình nội tâm",
                "content": "<h3>Giọng nói phê bình nội tâm</h3><p>Nhiều người trong chúng ta có một giọng nói nội tâm chỉ trích, phán xét và hạ thấp bản thân. Giọng nói này thường phát triển để bảo vệ chúng ta, nhưng nó có thể trở nên khắc nghiệt và có hại.</p>"
            },
            {
                "id": "critic-notice",
                "type": "doc",
                "title": "Nhận ra giọng nói phê bình",
                "content": "<h3>Nhận ra giọng nói phê bình</h3><p>Bước đầu tiên là <strong>nhận thấy</strong> khi giọng nói phê bình của bạn đang nói. Nó nói gì? Giọng điệu như thế nào? Bạn có nói chuyện như thế với một người bạn không?</p>"
            },
            {
                "id": "critic-says",
                "type": "journal_prompt",
                "question": "Giọng nói phê bình nội tâm của tôi thường nói gì với tôi?",
                "config": { "allowAI": true }
            },
            {
                "id": "critic-friend",
                "type": "journal_prompt",
                "question": "Một người bạn tử tế sẽ nói gì thay vào đó?",
                "config": { "allowAI": true }
            },
            {
                "id": "critic-completion",
                "type": "completion",
                "title": "Giọng nói nội tâm đã được nhận ra",
                "content": "Nhận thức về giọng nói phê bình của bạn là bước đầu tiên để thay đổi cuộc trò chuyện.",
                "recommended_next": [
                    {
                        "slide_group_id": "self-compassion-practice",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Thực hành tự thương yêu",
                        "description": "Một bài tập đơn giản để nuôi dưỡng sự tử tế."
                    }
                ]
            }
        ]
    },
    {
        "id": "self-compassion-practice",
        "title": "Thực hành tự thương yêu",
        "description": "Một bài tập đơn giản để nuôi dưỡng lòng tự trắc ẩn trong những lúc khó khăn.",
        "position": 3,
        "slides": [
            {
                "id": "practice-break",
                "type": "doc",
                "title": "Khoảnh khắc tự thương yêu bản thân",
                "content": "<h3>Khoảnh khắc tự thương yêu bản thân</h3><p>Khi bạn đang gặp khó khăn, hãy thử ba cụm từ này: <strong>1.</strong> 'Đây là một khoảnh khắc đau khổ.' <strong>2.</strong> 'Đau khổ là một phần của cuộc sống.' <strong>3.</strong> 'Hãy để tôi tử tế với bản thân.'</p>"
            },
            {
                "id": "practice-physical",
                "type": "doc",
                "title": "Tự thương yêu qua thể chất",
                "content": "<h3>Tự thương yêu qua thể chất</h3><p>Đặt tay lên tim hoặc ôm nhẹ bản thân. Sự chạm chân thể chất giải phóng oxytocin và có thể xoa dịu hệ thần kinh của bạn.</p>"
            },
            {
                "id": "practice-kind",
                "type": "journal_prompt",
                "question": "Một điều tử tế tôi có thể làm cho bản thân hôm nay là gì?",
                "config": { "allowAI": true }
            },
            {
                "id": "practice-gentle",
                "type": "journal_prompt",
                "question": "Tôi có thể nhẹ nhàng hơn với bản thân trong tuần này như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "practice-kindness-rating",
                "type": "star_rating",
                "question": "Bạn đã tử tế với bản thân hôm nay thế nào?",
                "config": {
                    "min": 1,
                    "max": 5
                }
            },
            {
                "id": "practice-completion",
                "type": "completion",
                "title": "Sự tử tế đã được thực hành",
                "content": "Tự thương yêu bản thân là một thực hành, không phải một đích đến. Mỗi hành động tử tế nhỏ với bản thân đều có giá trị.",
                "recommended_next": [
                    {
                        "slide_group_id": "self-forgiveness",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Tự tha thứ",
                        "description": "Giải phóng cảm giác tội lỗi và xấu hổ qua việc tự tha thứ."
                    },
                    {
                        "slide_group_id": "what-is-mindfulness",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Chánh niệm",
                        "description": "Kết hợp chánh niệm với tự thương yêu bản thân."
                    }
                ]
            }
        ]
    },
    {
        "id": "self-forgiveness",
        "title": "Tự tha thứ",
        "description": "Học cách giải phóng cảm giác tội lỗi và xấu hổ qua việc tự tha thứ.",
        "position": 4,
        "slides": [
            {
                "id": "forgive-why",
                "type": "doc",
                "title": "Tại sao việc tự tha thứ quan trọng",
                "content": "<h3>Tại sao việc tự tha thứ quan trọng</h3><p>Giữ cảm giác tội lỗi và xấu hổ khiến chúng ta bị mắc kẹt. Tự tha thứ không có nghĩa là bào chữa cho hành vi có hại — mà là <strong>giải phóng gánh nặng</strong> để bạn có thể tiến về phía trước và làm tốt hơn.</p>"
            },
            {
                "id": "forgive-holding",
                "type": "journal_prompt",
                "question": "Điều gì tôi vẫn đang chống lại bản thân?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-mean",
                "type": "journal_prompt",
                "question": "Thực sự tha thứ cho bản thân về điều này có ý nghĩa gì?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-learned",
                "type": "journal_prompt",
                "question": "Tôi đã học được gì từ trải nghiệm này?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-amends",
                "type": "journal_prompt",
                "question": "Tôi có thể bồi thường — với bản thân hay người khác — và tiến về phía trước như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-completion",
                "type": "completion",
                "title": "Tự do đã được lựa chọn",
                "content": "Tự tha thứ là hành động dũng cảm và yêu bản thân. Bạn xứng đáng được tiến về phía trước.",
                "metric_label": "Hoàn tất bộ sưu tập Tự thương yêu bản thân",
                "recommended_next": [
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Biết ơn hàng ngày",
                        "description": "Chuyển sự chú ý sang sự trân trọng."
                    },
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Hiểu về cảm xúc",
                        "description": "Nâng cao nhận thức cảm xúc về bản thân."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'b0b08888-b0b0-4888-b0b0-b0b0b0b08888';


-- ============================================================================
-- Collection 12: Check-Ins (66666666-...) — journal
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "daily-checkin",
        "title": "Ghi nhận hàng ngày",
        "description": "Câu hỏi nhanh để ghi nhận trạng thái của bản thân mỗi ngày và nhận thức trạng thái tâm trí.",
        "position": 1,
        "slides": [
            {
                "id": "daily-mood",
                "type": "emotion_log",
                "question": "Tôi đang cảm thấy thế nào hôm nay?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Bão tố", "Mưa to", "Mưa", "Nhiều mây", "Mây rải rác", "Hầu hết nắng", "Nắng", "Sáng rỡ", "Rạng ngời", "Hạnh phúc"]
                }
            },
            {
                "id": "daily-energy",
                "type": "sleep_check",
                "question": "Mức năng lượng của bạn ngay lúc này như thế nào?",
                "config": { "min": 0, "max": 100 }
            },
            {
                "id": "daily-feeling",
                "type": "journal_prompt",
                "question": "Tôi đang cảm thấy thế nào hôm nay?",
                "config": { "allowAI": true }
            },
            {
                "id": "daily-obstacles",
                "type": "journal_prompt",
                "question": "Tôi đang đối mặt với những trở ngại nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "daily-learning",
                "type": "journal_prompt",
                "question": "Tôi đang học được gì từ những trở ngại này?",
                "config": { "allowAI": true }
            },
            {
                "id": "daily-notes",
                "type": "journal_prompt",
                "question": "Ghi chú / Suy ngẫm",
                "config": { "allowAI": true }
            },
            {
                "id": "daily-checkin-completion",
                "type": "completion",
                "title": "Đã ghi nhận!",
                "content": "Nhận thức hàng ngày tích lũy theo thời gian. Tiếp tục hiện diện vì bản thân.",
                "recommended_next": [
                    {
                        "slide_group_id": "emotional-checkin",
                        "collection_id": "66666666-6666-4666-6666-666666666666",
                        "title": "Ghi nhận cảm xúc",
                        "description": "Đi sâu hơn vào trạng thái cảm xúc của bạn."
                    },
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Biết ơn hàng ngày",
                        "description": "Thêm lòng biết ơn vào thực hành hàng ngày."
                    }
                ]
            }
        ]
    },
    {
        "id": "emotional-checkin",
        "title": "Ghi nhận cảm xúc",
        "description": "Suy ngẫm về cảm xúc để hiểu tác nhân, phản ứng và cách hỗ trợ bản thân.",
        "position": 2,
        "slides": [
            {
                "id": "emo-current-mood",
                "type": "emotion_log",
                "question": "Cảm xúc bạn đang cảm thấy ngay lúc này mạnh mẽ đến mức nào?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Gần như không đáng kể", "Mờ nhạt", "Nhẹ", "Dễ nhận thấy", "Vừa phải", "Mạnh", "Rất mạnh", "Dữ dội", "Áp đảo", "Toàn bộ con người"]
                }
            },
            {
                "id": "emo-feeling",
                "type": "journal_prompt",
                "question": "Tôi đang cảm thấy cảm xúc gì ngay bây giờ?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-trigger",
                "type": "journal_prompt",
                "question": "Điều gì có thể đã kích hoạt cảm xúc này?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-respond",
                "type": "journal_prompt",
                "question": "Tôi đang phản ứng với cảm xúc này như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-last",
                "type": "journal_prompt",
                "question": "Lần cuối tôi cảm thấy như thế này là khi nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-affect",
                "type": "journal_prompt",
                "question": "Cảm xúc này ảnh hưởng đến suy nghĩ và hành vi của tôi như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-learn",
                "type": "journal_prompt",
                "question": "Tôi có thể học được gì từ cảm xúc này?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-support",
                "type": "journal_prompt",
                "question": "Tôi có thể tự hỗ trợ bản thân qua cảm xúc này như thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-checkin-completion",
                "type": "completion",
                "title": "Nhận thức cảm xúc đã được sâu sắc hơn",
                "content": "Mỗi lần bạn ghi nhận cảm xúc của mình, bạn xây dựng sự hiểu biết về bản thân.",
                "recommended_next": [
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Hiểu về cảm xúc",
                        "description": "Tìm hiểu thêm về mục đích của cảm xúc."
                    },
                    {
                        "slide_group_id": "what-is-mindfulness",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Chánh niệm",
                        "description": "Quan sát cảm xúc với nhận thức chánh niệm."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = '66666666-6666-4666-6666-666666666666';
