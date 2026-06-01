-- Migration 000038: Fix Vietnamese translations Part 2 — Collections 7-12
-- Continuation of 000037 (Collections 1-6)

-- ============================================================================
-- Collection 7: Relationships (dddd4444)
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "relationship-audit",
        "title": "Đánh giá mối quan hệ",
        "description": "Suy ngẫm về các mối quan hệ và tác động của chúng đến sức khỏe tinh thần.",
        "position": 1,
        "slides": [
            {
                "id": "rel-nurture",
                "type": "doc",
                "title": "Mối quan hệ nào nuôi dưỡng bạn?",
                "content": "<h3>Mối quan hệ nào nuôi dưỡng bạn?</h3><p>Mối quan hệ tốt cho bạn <strong>năng lượng</strong> và cảm giác được kết nối. Chúng khiến bạn cảm thấy an toàn, được tôn trọng và được lắng nghe.</p>"
            },
            {
                "id": "rel-drain",
                "type": "doc",
                "title": "Mối quan hệ nào làm bạn kiệt sức?",
                "content": "<h3>Mối quan hệ nào làm bạn kiệt sức?</h3><p>Một số mối quan hệ <strong>tiêu hao năng lượng</strong> — khiến bạn lo lắng, tự nghi ngờ hoặc cảm thấy không đủ tốt. Nhận ra chúng là bước đầu tiên để thiết lập ranh giới.</p>"
            },
            {
                "id": "rel-nurturing",
                "type": "journal_prompt",
                "question": "Mối quan hệ nào cho mình năng lượng, mối quan hệ nào làm mình kiệt sức?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-taken-for-granted",
                "type": "journal_prompt",
                "question": "Ai là người mình hay coi như hiển nhiên nhưng thực ra rất biết ơn?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-gratitude-recent",
                "type": "journal_prompt",
                "question": "Gần đây ai đã làm điều gì cho mình mà mình biết ơn?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-express",
                "type": "journal_prompt",
                "question": "Tuần này mình có thể bày tỏ lòng biết ơn với ai, bằng cách nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-boundaries",
                "type": "doc",
                "title": "Ranh giới là gì?",
                "content": "<h3>Ranh giới là gì?</h3><p>Ranh giới là <strong>giới hạn</strong> bạn đặt ra để bảo vệ sức khỏe tinh thần. Ranh giới tốt không phải là tường — chúng giống hàng rào có cổng, cho phép bạn chọn điều gì vào cuộc sống mình.</p>"
            },
            {
                "id": "rel-saying-no",
                "type": "journal_prompt",
                "question": "Điều gì khiến mình khó nói lời từ chối?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-communicate",
                "type": "journal_prompt",
                "question": "Mình có thể nói lên ranh giới của mình một cách tử tế mà vẫn rõ ràng?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-letting-go",
                "type": "journal_prompt",
                "question": "Việc giữ mãi điều này ảnh hưởng đến mình ra sao?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-audit-completion",
                "type": "completion",
                "title": "Nhẹ nhõm hơn rồi",
                "content": "Bạn đã suy ngẫm về mối quan hệ của mình. Hiểu chúng là bước đầu tiên để nuôi dưỡng kết nối lành mạnh.",
                "metric_label": "Đánh giá mối quan hệ hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Biết ơn hàng ngày",
                        "description": "Tiếp tục nuôi dưỡng lòng biết ơn trong các mối quan hệ."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Yêu thương bản thân",
                        "description": "Học cách tử tế với bản thân trong các mối quan hệ."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'dddd4444-dddd-4444-dddd-dddddddd4444';


-- ============================================================================
-- Collection 8: Gratitude (eeee5555)
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "daily-gratitude",
        "title": "Biết ơn hàng ngày",
        "description": "Luyện tập lòng biết ơn để chuyển sự chú ý sang điều tích cực.",
        "position": 1,
        "slides": [
            {
                "id": "gratitude-what",
                "type": "doc",
                "title": "Lòng biết ơn là gì?",
                "content": "<h3>Lòng biết ơn là gì?</h3><p>Lòng biết ơn là nhận ra và trân trọng <strong>những điều tốt đẹp</strong> trong cuộc sống — từ người thân yêu, đến sức khỏe, đến khoảnh khắc nhỏ bình yên. Nó không phải là phớt lờ khó khăn, mà là cân bằng lại.</p>"
            },
            {
                "id": "gratitude-why",
                "type": "doc",
                "title": "Tại sao lòng biết ơn quan trọng",
                "content": "<h3>Tại sao lòng biết ơn quan trọng</h3><p>Nghiên cứu cho thấy biết ơn thường xuyên <strong>tăng hạnh phúc</strong>, <strong>cải thiện giấc ngủ</strong>, <strong>giảm trầm cảm</strong> và <strong>tăng cường miễn dịch</strong>. Nó huấn luyện não bộ tìm kiếm điều tích cực.</p>"
            },
            {
                "id": "gratitude-three",
                "type": "journal_prompt",
                "question": "Ba điều mình cảm thấy biết ơn ngay bây giờ là gì?",
                "config": { "allowAI": true, "minLength": 20 }
            },
            {
                "id": "gratitude-why-these",
                "type": "journal_prompt",
                "question": "Tại sao ba điều này lại quan trọng với mình?",
                "config": { "allowAI": true }
            },
            {
                "id": "gratitude-positive",
                "type": "journal_prompt",
                "question": "Có điều gì tích cực nảy sinh từ một tình huống khó khăn không?",
                "config": { "allowAI": true }
            },
            {
                "id": "gratitude-rating",
                "type": "star_rating",
                "question": "Bạn cảm thấy bao nhiêu lòng biết ơn lúc này?",
                "config": { "min": 1, "max": 5 }
            },
            {
                "id": "gratitude-completion",
                "type": "completion",
                "title": "Cảm ơn vì đã sẻ chia",
                "content": "Lòng biết ơn giống như cơ bắp — càng luyện tập càng mạnh. Bạn đang xây dựng thói quen tích cực.",
                "metric_label": "Luyện tập biết ơn hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Yêu thương bản thân",
                        "description": "Kết hợp lòng biết ơn với sự tử tế với bản thân."
                    },
                    {
                        "slide_group_id": "morning-prep",
                        "collection_id": "55555555-5555-5555-5555-555555555555",
                        "title": "Suy ngẫm buổi sáng",
                        "description": "Bắt đầu ngày mới với lòng biết ơn."
                    }
                ]
            }
        ]
    },
    {
        "id": "gratitude-deep",
        "title": "Biết ơn sâu sắc",
        "description": "Khám phá lòng biết ơn sâu hơn trong các mối quan hệ và trải nghiệm.",
        "position": 2,
        "slides": [
            {
                "id": "gratitude-person",
                "type": "journal_prompt",
                "question": "Viết một lời biết ơn ngắn gửi ai đó quan trọng với mình.",
                "config": { "allowAI": true, "minLength": 30 }
            },
            {
                "id": "gratitude-moment",
                "type": "journal_prompt",
                "question": "Mô tả một khoảnh khắc gần đây khiến mình mỉm cười.",
                "config": { "allowAI": true }
            },
            {
                "id": "gratitude-self",
                "type": "journal_prompt",
                "question": "Điều gì về bản thân mình cảm thấy biết ơn hôm nay?",
                "config": { "allowAI": true }
            },
            {
                "id": "gratitude-savor",
                "type": "journal_prompt",
                "question": "Khoảnh khắc nào mình muốn lưu giữ mãi?",
                "config": { "allowAI": true }
            },
            {
                "id": "gratitude-deep-completion",
                "type": "completion",
                "title": "Góc nhìn mới mở ra",
                "content": "Lòng biết ơn sâu sắc giúp bạn thấy thế giới khác đi — ấm áp và đầy ý nghĩa hơn.",
                "metric_label": "Biết ơn sâu sắc hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "relationship-audit",
                        "collection_id": "dddd4444-dddd-4444-dddd-dddddddd4444",
                        "title": "Đánh giá mối quan hệ",
                        "description": "Suy ngẫm về các mối quan hệ quan trọng."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'eeee5555-eeee-4555-eeee-eeeeeeee5555';


-- ============================================================================
-- Collection 9: Understanding Emotions (ffff6666)
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "what-are-emotions",
        "title": "Cảm xúc là gì?",
        "description": "Hiểu mục đích của cảm xúc và cách chúng giao tiếp với bạn.",
        "position": 1,
        "slides": [
            {
                "id": "emo-purpose",
                "type": "doc",
                "title": "Cảm xúc có mục đích",
                "content": "<h3>Cảm xúc có mục đích</h3><p>Mỗi cảm xúc là <strong>tín hiệu</strong> từ cơ thể và tâm trí. Vui vẻ gợi kết nối, buồn bã yêu cầu sự hỗ trợ, giận dữ bảo vệ ranh giới, và sợ hãi giữ bạn an toàn. Không có cảm xúc 'xấu' — chỉ có thông điệp khác nhau.</p>"
            },
            {
                "id": "emo-not-facts",
                "type": "doc",
                "title": "Cảm xúc không phải là sự thật",
                "content": "<h3>Cảm xúc không phải là sự thật</h3><p>Cảm thấy thiếu sót không có nghĩa bạn thiếu sót. Cảm thấy sợ không có nghĩa bạn đang gặp nguy hiểm. Cảm xúc là <strong>dữ liệu</strong>, không phải <strong>sự thật</strong>. Học cách tách biệt hai điều này là kỹ năng mạnh mẽ.</p>"
            },
            {
                "id": "emo-spectrum",
                "type": "doc",
                "title": "Phổ cảm xúc",
                "content": "<h3>Phổ cảm xúc</h3><p>Con người trải nghiệm nhiều cảm xúc — từ niềm vui đến buồn bã, từ bình tĩnh đến lo âu. Tất cả đều bình thường. Mục tiêu không phải chỉ cảm thấy tốt, mà là <strong>hiểu và chấp nhận</strong> tất cả cảm xúc của mình.</p>"
            },
            {
                "id": "emo-what-completion",
                "type": "completion",
                "title": "Bạn thật dũng cảm",
                "content": "Hiểu cảm xúc cần sự dũng cảm. Bây giờ hãy khám phá cảm xúc của riêng bạn sâu hơn.",
                "metric_label": "Bài học hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "emotional-checkin",
                        "collection_id": "66666666-6666-4666-6666-666666666666",
                        "title": "Check-in cảm xúc",
                        "description": "Kiểm tra cảm xúc hiện tại của bạn."
                    },
                    {
                        "slide_group_id": "emotional-deep-dive",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Đào sâu cảm xúc",
                        "description": "Khám phá cảm xúc khó khăn an toàn hơn."
                    }
                ]
            }
        ]
    },
    {
        "id": "emotional-deep-dive",
        "title": "Đào sâu cảm xúc",
        "description": "Khám phá cảm xúc khó khăn an toàn và có hướng dẫn.",
        "position": 2,
        "slides": [
            {
                "id": "deep-safe",
                "type": "doc",
                "title": "Không gian an toàn của bạn",
                "content": "<h3>Không gian an toàn của bạn</h3><p>Phần này mời bạn khám phá cảm xúc <strong>khó khăn</strong>. Hãy nhớ: bạn luôn có thể dừng lại hoặc bỏ qua bất kỳ câu hỏi nào. Đi theo tốc độ của riêng bạn.</p>"
            },
            {
                "id": "deep-intensity",
                "type": "emotion_log",
                "question": "Cảm xúc bạn đang có lúc này mạnh đến đâu?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Gần như không", "Rất nhẹ", "Nhẹ", "Dễ nhận thấy", "Vừa phải", "Khá mạnh", "Mạnh", "Rất mạnh", "Dữ dội", "Áp đảo"]
                }
            },
            {
                "id": "deep-identify",
                "type": "journal_prompt",
                "question": "Mình đang có cảm xúc gì lúc này? Và cảm giác đó nằm ở đâu trong cơ thể?",
                "config": { "allowAI": true, "minLength": 30 }
            },
            {
                "id": "deep-trigger",
                "type": "journal_prompt",
                "question": "Điều gì có thể đã gây ra cảm xúc này?",
                "config": { "allowAI": true }
            },
            {
                "id": "deep-message",
                "type": "journal_prompt",
                "question": "Cảm xúc này đang muốn nói cho mình biết điều gì?",
                "config": { "allowAI": true }
            },
            {
                "id": "deep-need",
                "type": "journal_prompt",
                "question": "Mình cần gì lúc này để vượt qua cảm giác này?",
                "config": { "allowAI": true }
            },
            {
                "id": "deep-avoiding",
                "type": "journal_prompt",
                "question": "Gần đây mình có đang trốn tránh cảm xúc nào không?",
                "config": { "allowAI": true }
            },
            {
                "id": "deep-pattern",
                "type": "journal_prompt",
                "question": "Tình huống nào thường làm mình bùng nổ cảm xúc?",
                "config": { "allowAI": true }
            },
            {
                "id": "deep-past",
                "type": "journal_prompt",
                "question": "Trải nghiệm quá khứ nào có thể liên quan đến cảm xúc này?",
                "config": { "allowAI": true }
            },
            {
                "id": "deep-react",
                "type": "journal_prompt",
                "question": "Khi bị kích động, mình thường phản ứng thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "deep-respond",
                "type": "journal_prompt",
                "question": "Lần tới khi bị kích động, mình có thể phản ứng khác đi thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "deep-current-react",
                "type": "journal_prompt",
                "question": "Mình đang phản ứng với cảm xúc này thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "deep-affect",
                "type": "journal_prompt",
                "question": "Cảm xúc này đang ảnh hưởng đến suy nghĩ và hành động của mình ra sao?",
                "config": { "allowAI": true }
            },
            {
                "id": "deep-self-support",
                "type": "journal_prompt",
                "question": "Mình có thể tự giúp mình vượt qua cảm xúc này thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "deep-completion",
                "type": "completion",
                "title": "Bạn đã hiểu rõ hơn về mình",
                "content": "Khám phá cảm xúc khó khăn không dễ dàng. Bạn đã thể hiện sự dũng cảm và khả năng phục hồi lớn.",
                "metric_label": "Hoàn tất tất cả bài học Hiểu về cảm xúc",
                "recommended_next": [
                    {
                        "slide_group_id": "self-compassion-practice",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Thực hành yêu thương bản thân",
                        "description": "Dịu dàng với bản thân sau khi khám phá cảm xúc khó khăn."
                    },
                    {
                        "slide_group_id": "grounding-techniques",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Kỹ thuật cân bằng",
                        "description": "Công cụ thực tế khi cảm xúc quá tải."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'ffff6666-ffff-4666-ffff-ffffffff6666';


-- ============================================================================
-- Collection 10: Mindfulness (a0a07777)
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "what-is-mindfulness",
        "title": "Chánh niệm là gì?",
        "description": "Hiểu chánh niệm và tại sao nó có lợi cho sức khỏe tinh thần.",
        "position": 1,
        "slides": [
            {
                "id": "mindful-defined",
                "type": "doc",
                "title": "Định nghĩa chánh niệm",
                "content": "<h3>Định nghĩa chánh niệm</h3><p>Chánh niệm là <strong>chú ý có chủ đích</strong> vào khoảnh khắc hiện tại mà không phán xét. Không phải cố làm tâm trí trống rỗng — mà là <strong>nhận thấy</strong> suy nghĩ và cảm xúc khi chúng xuất hiện.</p>"
            },
            {
                "id": "mindful-benefits",
                "type": "doc",
                "title": "Lợi ích của chánh niệm",
                "content": "<h3>Lợi ích của chánh niệm</h3><ul><li>Giảm căng thẳng và lo âu</li><li>Cải thiện tập trung và rõ ràng</li><li>Tăng nhận thức cảm xúc</li><li>Tăng cường khả năng phục hồi</li></ul>"
            },
            {
                "id": "mindful-misconceptions",
                "type": "doc",
                "title": "Hiểu lầm phổ biến",
                "content": "<h3>Hiểu lầm phổ biến</h3><p>Chánh niệm <strong>không phải</strong> trống rỗng tâm trí, tránh cảm xúc hay thiền trong nhiều giờ. Nó đơn giản là <strong>hiện diện</strong> với bất cứ điều gì đang xảy ra ngay bây giờ — với sự tò mò thay vì phán xét.</p>"
            },
            {
                "id": "mindful-what-completion",
                "type": "completion",
                "title": "Hiểu chánh niệm",
                "content": "Bây giờ bạn đã biết chánh niệm là gì. Hãy thử bài tập thở đầu tiên.",
                "metric_label": "Bài học hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "mindful-breathing",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Thở có ý thức",
                        "description": "Một bài tập thở đơn giản để bắt đầu."
                    }
                ]
            }
        ]
    },
    {
        "id": "mindful-breathing",
        "title": "Thở có ý thức",
        "description": "Một bài tập thở đơn giản để mang bạn về hiện tại.",
        "position": 2,
        "slides": [
            {
                "id": "breath-why",
                "type": "doc",
                "title": "Tại sao hơi thở quan trọng",
                "content": "<h3>Tại sao hơi thở quan trọng</h3><p>Hơi thở là <strong>cầu nối</strong> giữa tâm trí và cơ thể. Khi lo âu, nhịp thở trở nên nông và nhanh. Bằng cách chủ động thở chậm và sâu, bạn gửi tín hiệu cho não bộ rằng bạn an toàn.</p>"
            },
            {
                "id": "breath-how",
                "type": "doc",
                "title": "Cách thực hành thở",
                "content": "<h3>Cách thực hành thở</h3><p>Đặt tay lên bụng. Hít vào qua mũi trong 4 nhịp đếm, cảm thấy bụng phình ra. Thở ra qua miệng trong 6 nhịp đếm, cảm thấy bụng xẹp xuống. Lặp lại 5 lần.</p>"
            },
            {
                "id": "breath-experience",
                "type": "journal_prompt",
                "question": "Sau khi thở sâu, mình cảm thấy khác thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "breath-cta-body",
                "type": "cta",
                "title": "Muốn đi sâu hơn?",
                "content": "Thử quét cơ thể để trải nghiệm chánh niệm toàn diện hơn.",
                "config": {
                    "slide_group_id": "body-scan",
                    "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777"
                }
            },
            {
                "id": "breath-completion",
                "type": "completion",
                "title": "Bước đầu tiên thành công",
                "content": "Bạn đã thực hành chánh niệm đầu tiên. Hơi thở luôn sẵn có — bất cứ lúc nào bạn cần.",
                "metric_label": "Thực hành thở hoàn tất",
                "recommended_next": [
                    {
                        "slide_group_id": "body-scan",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Quét cơ thể",
                        "description": "Kết nối với cảm giác thể chất."
                    },
                    {
                        "slide_group_id": "mindful-moments",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Khoảnh khắc chánh niệm",
                        "description": "Thực hành chánh niệm qua viết nhật ký."
                    }
                ]
            }
        ]
    },
    {
        "id": "body-scan",
        "title": "Quét cơ thể",
        "description": "Bài tập hướng dẫn để kết nối với cảm giác thể chất và giải phóng căng thẳng.",
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
                "content": "<h3>Lợi ích của quét cơ thể</h3><p>Quét cơ thể giúp bạn nhận ra nơi bạn đang giữ căng thẳng, kết nối lại với cơ thể và làm dịu hệ thần kinh. Rất hữu ích trước khi ngủ hoặc trong những lúc căng thẳng.</p>"
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
                "title": "Đã kết nối với cơ thể",
                "content": "Thực hành quét cơ thể thường xuyên giúp bạn duy trì kết nối với cơ thể.",
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
                "question": "Ngay lúc này mình đang nhận thấy điều gì — suy nghĩ, cảm xúc, hay cảm giác?",
                "config": { "allowAI": true }
            },
            {
                "id": "moment-sounds",
                "type": "journal_prompt",
                "question": "Mình có thể nghe thấy những âm thanh gì trong khoảnh khắc này?",
                "config": { "allowAI": true }
            },
            {
                "id": "moment-tension",
                "type": "journal_prompt",
                "question": "Mình thấy căng ở đâu trong cơ thể? Thử buông lỏng chỗ đó được không?",
                "config": { "allowAI": true }
            },
            {
                "id": "moment-appreciate",
                "type": "journal_prompt",
                "question": "Có điều gì trong khoảnh khắc này mà mình có thể biết ơn không?",
                "config": { "allowAI": true }
            },
            {
                "id": "moment-rating",
                "type": "star_rating",
                "question": "Bạn thấy mình tập trung vào bài này đến mức nào?",
                "config": {
                    "min": 1,
                    "max": 5
                }
            },
            {
                "id": "moment-completion",
                "type": "completion",
                "title": "Tuyệt! Bạn đã hiểu thêm về mình",
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
                        "title": "Yêu thương bản thân",
                        "description": "Thêm lòng trắc ẩn vào thực hành chánh niệm."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'a0a07777-a0a0-4777-a0a0-a0a0a0a07777';


-- ============================================================================
-- Collection 11: Self-Compassion (b0b08888)
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "what-is-self-compassion",
        "title": "Yêu thương bản thân là gì?",
        "description": "Hiểu về yêu thương bản thân và tại sao nó khác với lòng tự trọng.",
        "position": 1,
        "slides": [
            {
                "id": "comp-defined",
                "type": "doc",
                "title": "Yêu thương bản thân là gì",
                "content": "<h3>Yêu thương bản thân là gì</h3><p>Yêu thương bản thân có nghĩa là đối xử với bản thân bằng sự <strong>tử tế, thấu hiểu và kiên nhẫn</strong> giống như bạn dành cho một người bạn đang gặp khó khăn.</p>"
            },
            {
                "id": "comp-elements",
                "type": "doc",
                "title": "Ba yếu tố của yêu thương bản thân",
                "content": "<h3>Ba yếu tố của yêu thương bản thân</h3><p><strong>1. Tự tử tế</strong> thay vì tự phán xét. <strong>2. Nhân loại chung</strong> — nhận ra rằng đau khổ là một phần của con người. <strong>3. Chánh niệm</strong> — giữ những cảm xúc đau đớn trong nhận thức cân bằng.</p>"
            },
            {
                "id": "comp-vs-esteem",
                "type": "doc",
                "title": "Yêu thương bản thân khác gì lòng tự trọng",
                "content": "<h3>Yêu thương bản thân khác gì lòng tự trọng</h3><p>Lòng tự trọng là đánh giá bản thân tích cực. Yêu thương bản thân là <strong>tử tế với bản thân bất kể thành công hay thất bại</strong>. Nó ổn định và vô điều kiện hơn.</p>"
            },
            {
                "id": "comp-what-completion",
                "type": "completion",
                "title": "Sự tử tế bắt đầu từ bên trong",
                "content": "Hiểu về yêu thương bản thân mở ra cánh cửa để có mối quan hệ nhẹ nhàng hơn với bản thân.",
                "metric_label": "Hoàn tất bài học",
                "recommended_next": [
                    {
                        "slide_group_id": "inner-critic",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Làm việc với tiếng nói chỉ trích",
                        "description": "Học cách nhận ra và làm dịu tiếng nói nội tâm khắc nghiệt."
                    }
                ]
            }
        ]
    },
    {
        "id": "inner-critic",
        "title": "Làm việc với tiếng nói chỉ trích",
        "description": "Học cách nhận ra và làm dịu tiếng nói nội tâm khắc nghiệt.",
        "position": 2,
        "slides": [
            {
                "id": "critic-what",
                "type": "doc",
                "title": "Tiếng nói chỉ trích nội tâm",
                "content": "<h3>Tiếng nói chỉ trích nội tâm</h3><p>Nhiều người trong chúng ta có một tiếng nói nội tâm chỉ trích, phán xét và hạ thấp bản thân. Tiếng nói này thường phát triển để bảo vệ chúng ta, nhưng nó có thể trở nên khắc nghiệt và có hại.</p>"
            },
            {
                "id": "critic-notice",
                "type": "doc",
                "title": "Nhận ra tiếng nói chỉ trích",
                "content": "<h3>Nhận ra tiếng nói chỉ trích</h3><p>Bước đầu tiên là <strong>nhận thấy</strong> khi tiếng nói chỉ trích đang nói. Nó nói gì? Giọng điệu như thế nào? Bạn có nói chuyện như thế với một người bạn không?</p>"
            },
            {
                "id": "critic-says",
                "type": "journal_prompt",
                "question": "Lúc tự chỉ trích, tiếng nói trong đầu mình thường nói gì?",
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
                "title": "Đã nhận ra tiếng nói nội tâm",
                "content": "Nhận thức về tiếng nói chỉ trích là bước đầu tiên để thay đổi cuộc trò chuyện.",
                "recommended_next": [
                    {
                        "slide_group_id": "self-compassion-practice",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Thực hành yêu thương bản thân",
                        "description": "Một bài tập đơn giản để nuôi dưỡng sự tử tế."
                    }
                ]
            }
        ]
    },
    {
        "id": "self-compassion-practice",
        "title": "Thực hành yêu thương bản thân",
        "description": "Một bài tập đơn giản để nuôi dưỡng lòng trắc ẩn trong những lúc khó khăn.",
        "position": 3,
        "slides": [
            {
                "id": "practice-break",
                "type": "doc",
                "title": "Khoảnh khắc yêu thương bản thân",
                "content": "<h3>Khoảnh khắc yêu thương bản thân</h3><p>Khi bạn đang gặp khó khăn, hãy thử ba cụm từ này: <strong>1.</strong> 'Đây là khoảnh khắc khó khăn.' <strong>2.</strong> 'Khó khăn là một phần của cuộc sống.' <strong>3.</strong> 'Hãy để mình tử tế với bản thân.'</p>"
            },
            {
                "id": "practice-physical",
                "type": "doc",
                "title": "Yêu thương bản thân qua thể chất",
                "content": "<h3>Yêu thương bản thân qua thể chất</h3><p>Đặt tay lên tim hoặc ôm nhẹ bản thân. Sự chạm vật lý giải phóng oxytocin và có thể xoa dịu hệ thần kinh của bạn.</p>"
            },
            {
                "id": "practice-kind",
                "type": "journal_prompt",
                "question": "Hôm nay mình có thể làm điều gì tử tế cho bản thân?",
                "config": { "allowAI": true }
            },
            {
                "id": "practice-gentle",
                "type": "journal_prompt",
                "question": "Tuần này mình có thể dịu dàng hơn với bản thân ra sao?",
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
                "title": "Đã thực hành tử tế",
                "content": "Yêu thương bản thân là một thực hành, không phải một đích đến. Mỗi hành động tử tế nhỏ với bản thân đều có giá trị.",
                "recommended_next": [
                    {
                        "slide_group_id": "self-forgiveness",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Tự tha thứ",
                        "description": "Giải phóng cảm giác tội lỗi qua việc tự tha thứ."
                    },
                    {
                        "slide_group_id": "what-is-mindfulness",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Chánh niệm",
                        "description": "Kết hợp chánh niệm với yêu thương bản thân."
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
                "title": "Tại sao tự tha thứ quan trọng",
                "content": "<h3>Tại sao tự tha thứ quan trọng</h3><p>Giữ cảm giác tội lỗi và xấu hổ khiến mình bị mắc kẹt. Tự tha thứ không có nghĩa là bào chữa cho hành vi có hại — mà là <strong>giải phóng gánh nặng</strong> để bạn có thể tiến về phía trước và làm tốt hơn.</p>"
            },
            {
                "id": "forgive-holding",
                "type": "journal_prompt",
                "question": "Mình vẫn đang cố chống lại điều gì?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-mean",
                "type": "journal_prompt",
                "question": "Tha thứ thật sự cho bản thân về chuyện này nghĩa là gì?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-learned",
                "type": "journal_prompt",
                "question": "Mình đã học được gì từ trải nghiệm này?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-amends",
                "type": "journal_prompt",
                "question": "Mình có thể bù đắp cho ai đó rồi bước tiếp thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-completion",
                "type": "completion",
                "title": "Tự do đã được lựa chọn",
                "content": "Tự tha thứ là hành động dũng cảm và yêu thương bản thân. Bạn xứng đáng được tiến về phía trước.",
                "metric_label": "Hoàn tất bộ sưu tập Yêu thương bản thân",
                "recommended_next": [
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Biết ơn hàng ngày",
                        "description": "Chuyển sự chú ý sang lòng biết ơn."
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
-- Collection 12: Check-Ins (66666666)
-- ============================================================================
UPDATE journal_templates SET slide_groups_vi = $$[
    {
        "id": "daily-checkin",
        "title": "Ghi nhận hàng ngày",
        "description": "Câu hỏi nhanh để ghi nhận trạng thái của bản thân mỗi ngày.",
        "position": 1,
        "slides": [
            {
                "id": "daily-mood",
                "type": "emotion_log",
                "question": "Bạn cảm thấy thế nào hôm nay?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Bão tố", "Mưa to", "Mưa", "Nhiều mây", "Mây rải rác", "Hầu hết nắng", "Nắng", "Sáng rỡ", "Rạng ngời", "Hạnh phúc"]
                }
            },
            {
                "id": "daily-energy",
                "type": "sleep_check",
                "question": "Mức năng lượng của bạn lúc này thế nào?",
                "config": { "min": 0, "max": 100 }
            },
            {
                "id": "daily-feeling",
                "type": "journal_prompt",
                "question": "Mình đang cảm thấy thế nào hôm nay?",
                "config": { "allowAI": true }
            },
            {
                "id": "daily-obstacles",
                "type": "journal_prompt",
                "question": "Mình đang đối mặt với những trở ngại nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "daily-learning",
                "type": "journal_prompt",
                "question": "Mình đang học được gì từ những trở ngại này?",
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
                        "title": "Check-in cảm xúc",
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
        "title": "Check-in cảm xúc",
        "description": "Suy ngẫm về cảm xúc để hiểu tác nhân, phản ứng và cách hỗ trợ bản thân.",
        "position": 2,
        "slides": [
            {
                "id": "emo-current-mood",
                "type": "emotion_log",
                "question": "Cảm xúc bạn đang có lúc này mạnh đến đâu?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Gần như không", "Rất nhẹ", "Nhẹ", "Dễ nhận thấy", "Vừa phải", "Khá mạnh", "Mạnh", "Rất mạnh", "Dữ dội", "Áp đảo"]
                }
            },
            {
                "id": "emo-feeling",
                "type": "journal_prompt",
                "question": "Mình đang có cảm xúc gì lúc này?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-trigger",
                "type": "journal_prompt",
                "question": "Điều gì có thể đã gây ra cảm xúc này?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-respond",
                "type": "journal_prompt",
                "question": "Mình đang phản ứng với cảm xúc này thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-last",
                "type": "journal_prompt",
                "question": "Lần cuối mình cảm thấy như thế này là khi nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-affect",
                "type": "journal_prompt",
                "question": "Cảm xúc này đang ảnh hưởng đến suy nghĩ và hành động của mình ra sao?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-learn",
                "type": "journal_prompt",
                "question": "Mình có thể học được gì từ cảm xúc này?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-support",
                "type": "journal_prompt",
                "question": "Mình có thể tự giúp mình vượt qua cảm xúc này thế nào?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-checkin-completion",
                "type": "completion",
                "title": "Bạn đã hiểu rõ hơn về mình",
                "content": "Mỗi lần bạn ghi nhận cảm xúc, bạn xây dựng sự hiểu biết về bản thân.",
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