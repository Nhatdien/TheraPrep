-- Migration 000028: Enrich templates with new slide types, cross-links, and completion slides
-- Adds: questionnaire slides, completion slides with recommended_next, CTA cross-references,
-- and integrates unused slide types (star_rating, date_picker, checklist_input, sleep_check)

-- ============================================================================
-- Collection 1: Daily Reflection (55555555-5555-5555-5555-555555555555) — journal
-- Adds: sleep_check to Evening, completion slides, CTA to Gratitude Practice
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "morning-prep",
        "title": "Morning",
        "description": "Start your day with mindful journaling and positive focus.",
        "position": 1,
        "slides": [
            {
                "id": "morning-mood",
                "type": "emotion_log",
                "question": "How are you feeling this morning?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Storm", "Heavy Rain", "Rain", "Cloudy", "Partly Cloudy", "Mostly Sunny", "Sunny", "Bright", "Radiant", "Blissful"]
                }
            },
            {
                "id": "morning-sleep",
                "type": "sleep_check",
                "question": "How many hours did you sleep last night?",
                "config": {
                    "min": 0,
                    "max": 12
                }
            },
            {
                "id": "morning-mind",
                "type": "journal_prompt",
                "question": "What is on my mind this morning?",
                "config": {
                    "allowAI": true,
                    "minLength": 20
                }
            },
            {
                "id": "morning-intentions",
                "type": "journal_prompt",
                "question": "What can I do to make today amazing?",
                "config": {
                    "allowAI": true,
                    "minLength": 20
                }
            },
            {
                "id": "morning-cta-gratitude",
                "type": "cta",
                "title": "Start with gratitude",
                "content": "A short gratitude exercise can set a positive tone for your day.",
                "config": {
                    "slide_group_id": "daily-gratitude",
                    "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555"
                }
            },
            {
                "id": "morning-completion",
                "type": "completion",
                "title": "Morning check-in done!",
                "content": "You have set your intentions for today. Come back this evening to reflect.",
                "metric_label": "Morning reflection complete",
                "recommended_next": [
                    {
                        "slide_group_id": "evening-reflection",
                        "collection_id": "55555555-5555-5555-5555-555555555555",
                        "title": "Evening Reflection",
                        "description": "Close your day with reflection and self-kindness."
                    },
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Daily Gratitude",
                        "description": "A simple practice to notice the good in your life."
                    }
                ]
            }
        ]
    },
    {
        "id": "evening-reflection",
        "title": "Evening",
        "description": "Close your day with reflection and self-kindness.",
        "position": 2,
        "slides": [
            {
                "id": "evening-mood",
                "type": "emotion_log",
                "question": "How are you feeling this evening?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Storm", "Heavy Rain", "Rain", "Cloudy", "Partly Cloudy", "Mostly Sunny", "Sunny", "Bright", "Radiant", "Blissful"]
                }
            },
            {
                "id": "evening-sleep-quality",
                "type": "sleep_check",
                "question": "How would you rate your energy level today?",
                "config": {
                    "min": 0,
                    "max": 100
                }
            },
            {
                "id": "evening-memorable",
                "type": "journal_prompt",
                "question": "What happened today worth remembering?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "evening-positive",
                "type": "journal_prompt",
                "question": "What went well today?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "evening-learning",
                "type": "journal_prompt",
                "question": "What did I learn today?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "evening-changes",
                "type": "journal_prompt",
                "question": "What would I have changed about today?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "evening-celebrate",
                "type": "journal_prompt",
                "question": "What can I celebrate today?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "evening-day-rating",
                "type": "star_rating",
                "question": "How would you rate your day overall?",
                "config": {
                    "min": 1,
                    "max": 5
                }
            },
            {
                "id": "evening-winddown",
                "type": "journal_prompt",
                "question": "How can I wind down, release the day, and rest now?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "evening-completion",
                "type": "completion",
                "title": "Day complete!",
                "content": "You have reflected on your day. Rest well tonight.",
                "metric_label": "Evening reflection complete",
                "recommended_next": [
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Understanding Emotions",
                        "description": "Learn about emotions and how to work with them."
                    },
                    {
                        "slide_group_id": "why-sleep-matters",
                        "collection_id": "cccc3333-cccc-4333-cccc-cccccccc3333",
                        "title": "Why Sleep Matters",
                        "description": "Learn about the vital role sleep plays in your health."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = '55555555-5555-5555-5555-555555555555';


-- ============================================================================
-- Collection 2: Therapy Preparation (33333333-3333-3333-3333-333333333333) — learn
-- Adds: questionnaire to Signs, date_picker for appointment, completion slides, CTAs
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "signs-need-therapy",
        "title": "Signs that you need therapy",
        "description": "Learn to recognize when it may be time to seek professional support.",
        "position": 1,
        "slides": [
            {
                "id": "sign-tearful",
                "type": "doc",
                "title": "You are tearful for no reason",
                "content": "<h3>You are tearful for no reason</h3><p>When doing everyday activities like reading or watching a movie, if you find yourself tearful for no clear reason, it may be a sign your emotions are full and you need someone to talk to.</p>"
            },
            {
                "id": "sign-negative",
                "type": "doc",
                "title": "You are always having negative emotions",
                "content": "<h3>You are always having negative emotions</h3><p>Persistent negative emotions can weigh heavily and may signal that professional support could help.</p>"
            },
            {
                "id": "sign-habits",
                "type": "doc",
                "title": "You slip back to unhealthy habits",
                "content": "<h3>You slip back to unhealthy habits</h3><p>Falling into old unhealthy habits can be a sign of deeper struggles that therapy may help address.</p>"
            },
            {
                "id": "sign-control",
                "type": "doc",
                "title": "You feel like your emotions are controlling you",
                "content": "<h3>You feel like your emotions are controlling you</h3><p>Experiences like rage outbursts, yelling, or nonstop thoughts about past failures can interfere with sleep and daily life. This may be a signal that support is needed.</p>"
            },
            {
                "id": "sign-disconnected",
                "type": "doc",
                "title": "You feel disconnected between your inner and outer world",
                "content": "<h3>You feel disconnected between your inner and outer world</h3><p>You might seem cheerful in social settings but feel very different inside. Having separate faces socially and privately can indicate disconnection.</p>"
            },
            {
                "id": "sign-relationships",
                "type": "doc",
                "title": "Your relationships are suffering",
                "content": "<h3>Your relationships are suffering</h3><p>When you feel distant from friends or family, it can point to issues with trust, self-esteem, or deeper emotional struggles.</p>"
            },
            {
                "id": "sign-self-check",
                "type": "questionnaire",
                "question": "Which of these signs resonate with you?",
                "content": "Select any that apply. There are no right or wrong answers.",
                "mode": "multi",
                "options": [
                    {"id": "tearful", "label": "Feeling tearful for no reason"},
                    {"id": "negative", "label": "Persistent negative emotions"},
                    {"id": "habits", "label": "Slipping back to unhealthy habits"},
                    {"id": "control", "label": "Emotions feel out of control"},
                    {"id": "disconnected", "label": "Feeling disconnected inside vs outside"},
                    {"id": "relationships", "label": "Relationships are suffering"}
                ]
            },
            {
                "id": "sign-reminder",
                "type": "doc",
                "title": "A reminder",
                "content": "<h3>A reminder</h3><p>These are just common signs — you do not need to have any of them to see a therapist. All you need is the desire to feel better and share what is on your chest.</p>"
            },
            {
                "id": "therapy-reflection",
                "type": "journal_prompt",
                "question": "After reading these signs, what resonates with you? What are you feeling right now?",
                "config": {
                    "allowAI": true,
                    "minLength": 30
                }
            },
            {
                "id": "signs-completion",
                "type": "completion",
                "title": "You took a brave step",
                "content": "Recognizing these signs takes courage. Knowing yourself better is the first step toward feeling better.",
                "metric_label": "Self-awareness exercise complete",
                "recommended_next": [
                    {
                        "slide_group_id": "what-to-know",
                        "collection_id": "33333333-3333-3333-3333-333333333333",
                        "title": "What I want my therapist to know",
                        "description": "Prepare what you want to share in your first session."
                    },
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Understanding Emotions",
                        "description": "Learn why emotions matter and how to work with them."
                    }
                ]
            }
        ]
    },
    {
        "id": "what-to-know",
        "title": "What I want my therapist to know",
        "description": "Reflect on what you would like to share in your first therapy session.",
        "position": 2,
        "slides": [
            {
                "id": "therapist-know-intro",
                "type": "doc",
                "title": "Preparing for your first session",
                "content": "<h3>Preparing for your first session</h3><p>Therapy can feel overwhelming at first. Taking time to reflect on what you want to share can help you feel more prepared and confident.</p><p>Use these prompts to explore what matters most to you right now.</p>"
            },
            {
                "id": "therapist-appointment-date",
                "type": "date_picker",
                "question": "When is your therapy appointment?",
                "config": {
                    "format": "YYYY-MM-DD"
                }
            },
            {
                "id": "therapist-main-concern",
                "type": "journal_prompt",
                "question": "What is the main thing bringing you to therapy right now?",
                "config": {
                    "allowAI": true,
                    "minLength": 30
                }
            },
            {
                "id": "therapist-goals",
                "type": "journal_prompt",
                "question": "What do you hope to achieve through therapy?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "therapist-struggles",
                "type": "journal_prompt",
                "question": "What has been most difficult for you lately?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "therapist-things-to-bring",
                "type": "checklist_input",
                "question": "What do you want to remember to bring up in your session?",
                "config": {
                    "placeholder": "Add a topic or question..."
                }
            },
            {
                "id": "therapist-support",
                "type": "journal_prompt",
                "question": "What kind of support do you think would be most helpful?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "therapist-cta-anxiety",
                "type": "cta",
                "title": "Feeling anxious about therapy?",
                "content": "Learn grounding techniques to help you feel calmer.",
                "config": {
                    "slide_group_id": "grounding-techniques",
                    "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222"
                }
            },
            {
                "id": "what-to-know-completion",
                "type": "completion",
                "title": "You are ready",
                "content": "You have taken a meaningful step in preparing for therapy. Having your thoughts organized can make your session much more productive.",
                "metric_label": "Therapy prep complete",
                "recommended_next": [
                    {
                        "slide_group_id": "what-is-anxiety",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Understanding Anxiety",
                        "description": "Learn about anxiety and how it differs from normal worry."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Self-Compassion",
                        "description": "Learn to treat yourself with kindness."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = '33333333-3333-3333-3333-333333333333';


-- ============================================================================
-- Collection 3: Stress Management (44444444-4444-4444-4444-444444444444) — journal
-- Adds: doc intro slides, questionnaire, CTA to Anxiety, completion slide
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "stress-check-in",
        "title": "Stress Check-In",
        "description": "Assess your current stress level and identify triggers.",
        "position": 1,
        "slides": [
            {
                "id": "stress-intro",
                "type": "doc",
                "title": "Understanding your stress",
                "content": "<h3>Understanding your stress</h3><p>Stress is a natural response, but chronic stress can harm your mind and body. This check-in helps you <strong>identify</strong> what is causing stress and <strong>plan</strong> a small step to reduce it.</p>"
            },
            {
                "id": "stress-level",
                "type": "emotion_log",
                "question": "How stressed are you feeling right now?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Calm", "Relaxed", "Comfortable", "Slightly Tense", "Moderate", "Stressed", "Very Stressed", "Overwhelmed", "Extreme", "Breaking Point"]
                }
            },
            {
                "id": "stress-type-check",
                "type": "questionnaire",
                "question": "What type of stress are you experiencing?",
                "content": "Select the primary source of your stress right now.",
                "mode": "single",
                "options": [
                    {"id": "work", "label": "Work or school", "description": "Deadlines, workload, performance pressure"},
                    {"id": "relationships", "label": "Relationships", "description": "Conflict, loneliness, social pressure"},
                    {"id": "health", "label": "Health concerns", "description": "Physical health, mental health, sleep"},
                    {"id": "financial", "label": "Financial", "description": "Money worries, bills, job security"},
                    {"id": "life-changes", "label": "Life changes", "description": "Moving, new job, loss, transitions"},
                    {"id": "general", "label": "General overwhelm", "description": "Everything feels like too much"}
                ]
            },
            {
                "id": "stress-sources",
                "type": "journal_prompt",
                "question": "What is causing you stress right now?",
                "config": {
                    "allowAI": true,
                    "minLength": 20
                }
            },
            {
                "id": "stress-body",
                "type": "journal_prompt",
                "question": "How is stress showing up in your body? (headaches, tension, fatigue, etc.)",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "stress-coping",
                "type": "journal_prompt",
                "question": "What has helped you cope with stress in the past?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "stress-action",
                "type": "journal_prompt",
                "question": "What is one small thing you can do today to reduce your stress?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "stress-cta-anxiety",
                "type": "cta",
                "title": "Feeling anxious alongside stress?",
                "content": "Learn techniques specifically designed for managing anxious thoughts.",
                "config": {
                    "slide_group_id": "challenging-thoughts",
                    "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222"
                }
            },
            {
                "id": "stress-checkin-completion",
                "type": "completion",
                "title": "Check-in complete",
                "content": "You have identified your stress and planned a step forward. That awareness is powerful.",
                "metric_label": "Stress check-in complete",
                "recommended_next": [
                    {
                        "slide_group_id": "grounding-techniques",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Grounding Techniques",
                        "description": "Practical techniques to calm your nervous system."
                    },
                    {
                        "slide_group_id": "what-is-mindfulness",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "What is Mindfulness?",
                        "description": "Learn mindfulness for present-moment calm."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = '44444444-4444-4444-4444-444444444444';


-- ============================================================================
-- Collection 4: Introduction to Journaling (22222222-...) — learn
-- Adds: completion slides with recommended_next, CTA to Daily Reflection
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "what-is-journaling",
        "title": "What is Journaling?",
        "description": "Learn what journaling is, why it matters, and how this app can support your practice.",
        "position": 1,
        "slides": [
            {
                "id": "journaling-intro",
                "type": "doc",
                "title": "What journaling is",
                "content": "<h3>What journaling is</h3><p>Journaling is simply writing down your <strong>thoughts</strong>, <strong>feelings</strong>, and <strong>experiences</strong> — kind of like having a quiet chat with yourself in a notebook or on your phone.</p>"
            },
            {
                "id": "journaling-why",
                "type": "doc",
                "title": "Why it matters",
                "content": "<h3>Why it matters</h3><p>Writing things out helps you <strong>express yourself</strong> and <strong>notice your thoughts</strong> more clearly. Think of your emotions as visitors — journaling lets you welcome them in, hear what they have to say, and then let them move on.</p>"
            },
            {
                "id": "journaling-app",
                "type": "doc",
                "title": "How this app helps",
                "content": "<h3>How this app helps</h3><p>Here, you will find <strong>daily prompts</strong> to reflect on your emotions, along with <strong>resources</strong> to help you feel more prepared and supported as you get ready for therapy.</p>"
            },
            {
                "id": "journaling-further",
                "type": "further_reading",
                "title": "Learn More",
                "content": "<h3>Further Reading</h3><ul><li><a href='https://dayoneapp.com/blog/journaling/'>What is Journaling - DayOne</a></li></ul>"
            },
            {
                "id": "journaling-what-completion",
                "type": "completion",
                "title": "Great start!",
                "content": "Now you know what journaling is. Next, learn about the powerful benefits it can bring.",
                "metric_label": "Lesson complete",
                "recommended_next": [
                    {
                        "slide_group_id": "benefits-journaling",
                        "collection_id": "22222222-2222-2222-2222-222222222222",
                        "title": "Benefits of Journaling",
                        "description": "Discover how journaling supports mental health."
                    },
                    {
                        "slide_group_id": "morning-prep",
                        "collection_id": "55555555-5555-5555-5555-555555555555",
                        "title": "Morning Reflection",
                        "description": "Try your first journal entry with morning prompts."
                    }
                ]
            }
        ]
    },
    {
        "id": "benefits-journaling",
        "title": "Benefits of Journaling",
        "description": "Discover how journaling supports mental health and emotional well-being.",
        "position": 2,
        "slides": [
            {
                "id": "benefit-awareness",
                "type": "doc",
                "title": "Promotes self-awareness",
                "content": "<h3>Promotes self-awareness and reflection</h3><p>Writing down thoughts and emotions helps identify patterns, triggers, and behaviors, enhancing understanding and self-awareness. This can also help track mental health progress over time.</p>"
            },
            {
                "id": "benefit-stress",
                "type": "doc",
                "title": "Reduces stress and anxiety",
                "content": "<h3>Reduces stress and anxiety</h3><p>Journaling is a cathartic experience that helps release pent-up emotions and lowers stress hormone levels, providing a sense of emotional control and empowerment.</p>"
            },
            {
                "id": "benefit-outlet",
                "type": "doc",
                "title": "Safe outlet for emotions",
                "content": "<h3>Provides a safe outlet for emotions</h3><p>It offers a private, non-judgmental space to express feelings, which is especially helpful for managing conditions like depression and anxiety.</p>"
            },
            {
                "id": "benefit-mood",
                "type": "doc",
                "title": "Improves mood",
                "content": "<h3>Improves mood and positivity</h3><p>Writing about positive experiences and gratitude can boost happiness, counter negative thought patterns, and improve overall emotional well-being.</p>"
            },
            {
                "id": "benefit-reflect",
                "type": "journal_prompt",
                "question": "What benefits of journaling are you most excited to experience?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "benefit-cta-daily",
                "type": "cta",
                "title": "Ready to start journaling?",
                "content": "Try a simple daily reflection to put what you have learned into practice.",
                "config": {
                    "slide_group_id": "morning-prep",
                    "collection_id": "55555555-5555-5555-5555-555555555555"
                }
            },
            {
                "id": "benefits-completion",
                "type": "completion",
                "title": "You are ready to begin!",
                "content": "You now understand why journaling matters. The best time to start is today.",
                "metric_label": "Introduction complete",
                "recommended_next": [
                    {
                        "slide_group_id": "morning-prep",
                        "collection_id": "55555555-5555-5555-5555-555555555555",
                        "title": "Morning Reflection",
                        "description": "Start your first journal entry with guided prompts."
                    },
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Understanding Emotions",
                        "description": "Learn about emotions to deepen your journaling practice."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = '22222222-2222-2222-2222-222222222222';


-- ============================================================================
-- Collection 5: Understanding Anxiety (bbbb2222-...) — learn
-- Adds: questionnaire for anxiety level, CTA to Mindfulness, completion slides
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "what-is-anxiety",
        "title": "What is Anxiety?",
        "description": "Understanding the nature of anxiety and how it differs from normal worry.",
        "position": 1,
        "slides": [
            {
                "id": "anxiety-natural",
                "type": "doc",
                "title": "Anxiety is a natural response",
                "content": "<h3>Anxiety is a natural response</h3><p>Anxiety is your body's <strong>alarm system</strong>. It is designed to protect you from danger by triggering the fight-or-flight response. The problem arises when this alarm goes off too often or too intensely.</p>"
            },
            {
                "id": "anxiety-vs-worry",
                "type": "doc",
                "title": "Worry vs. Anxiety",
                "content": "<h3>Worry vs. Anxiety</h3><p><strong>Worry</strong> is mental — it is the thoughts about what might go wrong. <strong>Anxiety</strong> is physical — it is the racing heart, tight chest, and sweaty palms that come with those thoughts.</p>"
            },
            {
                "id": "anxiety-symptoms",
                "type": "doc",
                "title": "Common symptoms",
                "content": "<h3>Common symptoms</h3><ul><li>Racing thoughts and difficulty concentrating</li><li>Restlessness and feeling on edge</li><li>Physical tension and headaches</li><li>Sleep difficulties</li><li>Avoidance of triggering situations</li></ul>"
            },
            {
                "id": "anxiety-level-check",
                "type": "questionnaire",
                "question": "How would you describe your anxiety right now?",
                "content": "Choose the option that best describes your current experience.",
                "mode": "single",
                "options": [
                    {"id": "minimal", "label": "Minimal", "description": "I feel mostly calm with occasional worry"},
                    {"id": "mild", "label": "Mild", "description": "I notice anxiety but it does not interfere much"},
                    {"id": "moderate", "label": "Moderate", "description": "Anxiety affects my daily activities sometimes"},
                    {"id": "significant", "label": "Significant", "description": "Anxiety is a constant presence in my life"}
                ]
            },
            {
                "id": "anxiety-what-completion",
                "type": "completion",
                "title": "Knowledge is power",
                "content": "Understanding anxiety is the first step to managing it. You are learning important skills.",
                "metric_label": "Lesson complete",
                "recommended_next": [
                    {
                        "slide_group_id": "anxiety-triggers",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Identifying Your Triggers",
                        "description": "Learn what situations activate your anxiety."
                    },
                    {
                        "slide_group_id": "grounding-techniques",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Grounding Techniques",
                        "description": "Practical techniques to use when anxiety strikes."
                    }
                ]
            }
        ]
    },
    {
        "id": "anxiety-triggers",
        "title": "Identifying Your Triggers",
        "description": "Learn to recognize what situations, thoughts, or patterns trigger your anxiety.",
        "position": 2,
        "slides": [
            {
                "id": "triggers-what",
                "type": "doc",
                "title": "What are triggers?",
                "content": "<h3>What are triggers?</h3><p>Triggers are situations, thoughts, or sensations that activate your anxiety response. They can be <strong>external</strong> (a work deadline, social event) or <strong>internal</strong> (a thought, physical sensation, memory).</p>"
            },
            {
                "id": "triggers-common",
                "type": "doc",
                "title": "Common anxiety triggers",
                "content": "<h3>Common anxiety triggers</h3><ul><li>Uncertainty about the future</li><li>Social situations and fear of judgment</li><li>Health concerns</li><li>Financial worries</li><li>Relationship conflicts</li><li>Past trauma or difficult memories</li></ul>"
            },
            {
                "id": "triggers-reflect",
                "type": "journal_prompt",
                "question": "What situations tend to trigger my anxiety the most?",
                "config": {
                    "allowAI": true,
                    "minLength": 20
                }
            },
            {
                "id": "triggers-pattern",
                "type": "journal_prompt",
                "question": "Are there any patterns I notice in when my anxiety appears?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "triggers-completion",
                "type": "completion",
                "title": "Great self-awareness",
                "content": "Knowing your triggers helps you prepare and respond rather than react.",
                "metric_label": "Triggers identified",
                "recommended_next": [
                    {
                        "slide_group_id": "grounding-techniques",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Grounding Techniques",
                        "description": "Learn practical techniques to calm your nervous system."
                    },
                    {
                        "slide_group_id": "challenging-thoughts",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Challenging Anxious Thoughts",
                        "description": "Learn to reframe the thinking patterns that fuel anxiety."
                    }
                ]
            }
        ]
    },
    {
        "id": "grounding-techniques",
        "title": "Grounding Techniques",
        "description": "Practical techniques to calm your nervous system when anxiety strikes.",
        "position": 3,
        "slides": [
            {
                "id": "grounding-54321",
                "type": "doc",
                "title": "The 5-4-3-2-1 technique",
                "content": "<h3>The 5-4-3-2-1 technique</h3><p>When anxiety overwhelms you, use your senses to ground yourself: Name <strong>5 things you can see</strong>, <strong>4 things you can touch</strong>, <strong>3 things you can hear</strong>, <strong>2 things you can smell</strong>, and <strong>1 thing you can taste</strong>.</p>"
            },
            {
                "id": "grounding-box",
                "type": "doc",
                "title": "Box breathing",
                "content": "<h3>Box breathing</h3><p>Breathe in for 4 counts, hold for 4 counts, breathe out for 4 counts, hold for 4 counts. Repeat until you feel calmer. This activates your parasympathetic nervous system.</p>"
            },
            {
                "id": "grounding-physical",
                "type": "doc",
                "title": "Physical grounding",
                "content": "<h3>Physical grounding</h3><p>Press your feet firmly into the floor, squeeze a stress ball, or hold something cold. Physical sensations help bring you back to the present moment.</p>"
            },
            {
                "id": "grounding-cta-mindfulness",
                "type": "cta",
                "title": "Want a deeper practice?",
                "content": "Try a guided body scan for a more thorough grounding experience.",
                "config": {
                    "slide_group_id": "body-scan",
                    "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777"
                }
            },
            {
                "id": "grounding-completion",
                "type": "completion",
                "title": "Techniques learned",
                "content": "You now have practical tools to use when anxiety strikes. Practice makes them more effective.",
                "metric_label": "Grounding techniques learned",
                "recommended_next": [
                    {
                        "slide_group_id": "challenging-thoughts",
                        "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222",
                        "title": "Challenging Anxious Thoughts",
                        "description": "Learn to identify and reframe thinking traps."
                    },
                    {
                        "slide_group_id": "mindful-breathing",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Mindful Breathing",
                        "description": "A deeper breathing practice for daily calm."
                    }
                ]
            }
        ]
    },
    {
        "id": "challenging-thoughts",
        "title": "Challenging Anxious Thoughts",
        "description": "Learn to identify and reframe the thinking patterns that fuel anxiety.",
        "position": 4,
        "slides": [
            {
                "id": "thoughts-distortions",
                "type": "doc",
                "title": "Cognitive distortions",
                "content": "<h3>Cognitive distortions</h3><p>Anxiety often involves <strong>thinking traps</strong> like catastrophizing (assuming the worst), mind-reading (assuming others think negatively of you), and all-or-nothing thinking.</p>"
            },
            {
                "id": "thoughts-question",
                "type": "doc",
                "title": "The questioning approach",
                "content": "<h3>The questioning approach</h3><p>When you notice an anxious thought, ask yourself: <em>Is this thought based on facts or feelings? What is the evidence for and against it? What would I tell a friend in this situation?</em></p>"
            },
            {
                "id": "thoughts-recurring",
                "type": "journal_prompt",
                "question": "What anxious thought keeps recurring for me?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "thoughts-evidence",
                "type": "journal_prompt",
                "question": "What evidence do I have that this thought might not be completely true?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "thoughts-completion",
                "type": "completion",
                "title": "Thoughts challenged",
                "content": "You are building the skill of questioning anxious thoughts. This gets easier with practice.",
                "metric_label": "All lessons in Understanding Anxiety complete",
                "recommended_next": [
                    {
                        "slide_group_id": "stress-check-in",
                        "collection_id": "44444444-4444-4444-4444-444444444444",
                        "title": "Stress Check-In",
                        "description": "Assess your stress level and plan a coping step."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Self-Compassion",
                        "description": "Learn to treat yourself with kindness during hard times."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222';


-- ============================================================================
-- Collection 6: Better Sleep (cccc3333-...) — learn
-- Adds: sleep_check slides, star_rating, completion slides, CTA to Mindfulness
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "why-sleep-matters",
        "title": "Why Sleep Matters",
        "description": "Understanding the vital role sleep plays in mental and physical health.",
        "position": 1,
        "slides": [
            {
                "id": "sleep-not-optional",
                "type": "doc",
                "title": "Sleep is not optional",
                "content": "<h3>Sleep is not optional</h3><p>Sleep is when your brain <strong>consolidates memories</strong>, <strong>processes emotions</strong>, and <strong>repairs cells</strong>. Poor sleep does not just make you tired — it affects mood, decision-making, and even immune function.</p>"
            },
            {
                "id": "sleep-mental",
                "type": "doc",
                "title": "The sleep-mental health connection",
                "content": "<h3>The sleep-mental health connection</h3><p>Sleep and mental health are deeply connected. Anxiety and depression can disrupt sleep, and poor sleep can worsen anxiety and depression. Breaking this cycle is key to feeling better.</p>"
            },
            {
                "id": "sleep-how-much",
                "type": "doc",
                "title": "How much sleep do you need?",
                "content": "<h3>How much sleep do you need?</h3><p>Most adults need <strong>7-9 hours</strong> of quality sleep. It is not just about quantity — the quality of your sleep matters too. Deep sleep and REM sleep are essential for restoration.</p>"
            },
            {
                "id": "sleep-quality-check",
                "type": "sleep_check",
                "question": "How would you rate your overall sleep quality this week?",
                "config": {
                    "min": 0,
                    "max": 100
                }
            },
            {
                "id": "sleep-matters-completion",
                "type": "completion",
                "title": "Good to know!",
                "content": "Understanding why sleep matters is the first step to sleeping better.",
                "metric_label": "Lesson complete",
                "recommended_next": [
                    {
                        "slide_group_id": "sleep-hygiene",
                        "collection_id": "cccc3333-cccc-4333-cccc-cccccccc3333",
                        "title": "Sleep Hygiene Basics",
                        "description": "Simple habits that promote better sleep."
                    }
                ]
            }
        ]
    },
    {
        "id": "sleep-hygiene",
        "title": "Sleep Hygiene Basics",
        "description": "Simple habits and environmental changes that promote better sleep.",
        "position": 2,
        "slides": [
            {
                "id": "hygiene-sanctuary",
                "type": "doc",
                "title": "Create a sleep sanctuary",
                "content": "<h3>Create a sleep sanctuary</h3><p>Keep your bedroom <strong>cool, dark, and quiet</strong>. Remove screens if possible. Your bed should be associated with sleep, not scrolling.</p>"
            },
            {
                "id": "hygiene-schedule",
                "type": "doc",
                "title": "Establish a consistent schedule",
                "content": "<h3>Establish a consistent schedule</h3><p>Go to bed and wake up at the same time every day — even on weekends. This helps regulate your body's internal clock.</p>"
            },
            {
                "id": "hygiene-winddown",
                "type": "doc",
                "title": "Wind-down routine",
                "content": "<h3>Wind-down routine</h3><p>Start relaxing 30-60 minutes before bed. Dim the lights, avoid screens, and do something calming like reading, stretching, or journaling.</p>"
            },
            {
                "id": "hygiene-checklist",
                "type": "checklist_input",
                "question": "What does your ideal bedtime routine look like?",
                "config": {
                    "placeholder": "Add a step to your routine..."
                }
            },
            {
                "id": "hygiene-change",
                "type": "journal_prompt",
                "question": "What one change could I make to improve my sleep environment?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "hygiene-completion",
                "type": "completion",
                "title": "Habits set!",
                "content": "Small changes to your sleep environment can make a big difference.",
                "metric_label": "Sleep hygiene learned",
                "recommended_next": [
                    {
                        "slide_group_id": "racing-thoughts",
                        "collection_id": "cccc3333-cccc-4333-cccc-cccccccc3333",
                        "title": "Calming Racing Thoughts",
                        "description": "Techniques to quiet the mind at bedtime."
                    },
                    {
                        "slide_group_id": "mindful-breathing",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Mindful Breathing",
                        "description": "A breathing practice perfect for bedtime."
                    }
                ]
            }
        ]
    },
    {
        "id": "racing-thoughts",
        "title": "Calming Racing Thoughts",
        "description": "Techniques to quiet the mind when thoughts keep you awake at night.",
        "position": 3,
        "slides": [
            {
                "id": "racing-dump",
                "type": "doc",
                "title": "The worry dump",
                "content": "<h3>The worry dump</h3><p>Before bed, write down everything on your mind. Get it out of your head and onto paper. You can deal with it tomorrow — right now, it is time to rest.</p>"
            },
            {
                "id": "racing-scan",
                "type": "doc",
                "title": "Body scan relaxation",
                "content": "<h3>Body scan relaxation</h3><p>Starting from your toes, slowly focus on relaxing each part of your body. Notice tension and consciously release it as you move upward.</p>"
            },
            {
                "id": "racing-478",
                "type": "doc",
                "title": "The 4-7-8 breath",
                "content": "<h3>The 4-7-8 breath</h3><p>Breathe in for 4 counts, hold for 7 counts, exhale slowly for 8 counts. This breathing pattern activates relaxation and helps quiet the mind.</p>"
            },
            {
                "id": "racing-cta-grounding",
                "type": "cta",
                "title": "Need more grounding tools?",
                "content": "Explore additional grounding techniques for when thoughts feel overwhelming.",
                "config": {
                    "slide_group_id": "grounding-techniques",
                    "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222"
                }
            },
            {
                "id": "racing-completion",
                "type": "completion",
                "title": "Rest techniques ready",
                "content": "Try one of these techniques tonight. With practice, they become more effective.",
                "metric_label": "Calming techniques learned",
                "recommended_next": [
                    {
                        "slide_group_id": "evening-sleep-reflection",
                        "collection_id": "cccc3333-cccc-4333-cccc-cccccccc3333",
                        "title": "Evening Reflection",
                        "description": "Journal prompts to process the day before sleep."
                    }
                ]
            }
        ]
    },
    {
        "id": "evening-sleep-reflection",
        "title": "Evening Reflection",
        "description": "Journal prompts to help you process the day and prepare for restful sleep.",
        "position": 4,
        "slides": [
            {
                "id": "sleep-tonight-quality",
                "type": "sleep_check",
                "question": "How tired do you feel right now?",
                "config": {
                    "min": 0,
                    "max": 100
                }
            },
            {
                "id": "sleep-grateful",
                "type": "journal_prompt",
                "question": "What are three things I am grateful for from today?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "sleep-letgo",
                "type": "journal_prompt",
                "question": "What can I let go of from today?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "sleep-onmind",
                "type": "journal_prompt",
                "question": "What thoughts are still on my mind that I can write down and release?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "sleep-tomorrow",
                "type": "journal_prompt",
                "question": "How do I want to feel when I wake up tomorrow?",
                "config": {
                    "allowAI": true
                }
            },
            {
                "id": "sleep-day-rating",
                "type": "star_rating",
                "question": "How would you rate your restfulness today?",
                "config": {
                    "min": 1,
                    "max": 5
                }
            },
            {
                "id": "sleep-reflection-completion",
                "type": "completion",
                "title": "Ready for rest",
                "content": "You have released the day. Sleep well tonight.",
                "metric_label": "All Better Sleep lessons complete",
                "recommended_next": [
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Daily Gratitude",
                        "description": "A gratitude practice for overall well-being."
                    },
                    {
                        "slide_group_id": "evening-reflection",
                        "collection_id": "55555555-5555-5555-5555-555555555555",
                        "title": "Evening Reflection",
                        "description": "A general evening journaling practice."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'cccc3333-cccc-4333-cccc-cccccccc3333';


-- ============================================================================
-- Collection 7: Relationships & Connection (dddd4444-...) — journal
-- Adds: completion slides, CTA to Understanding Emotions
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "relationship-reflection",
        "title": "Relationship Reflection",
        "description": "Reflect on the quality and patterns in your closest relationships.",
        "position": 1,
        "slides": [
            {
                "id": "rel-important",
                "type": "journal_prompt",
                "question": "Who are the most important people in my life right now?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-show-love",
                "type": "journal_prompt",
                "question": "How do I show love and appreciation to those closest to me?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-nourish-drain",
                "type": "journal_prompt",
                "question": "What relationships feel nourishing, and which feel draining?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-neglect",
                "type": "journal_prompt",
                "question": "Is there a relationship I have been neglecting that I want to nurture?",
                "config": { "allowAI": true }
            },
            {
                "id": "rel-reflection-completion",
                "type": "completion",
                "title": "Reflection complete",
                "content": "Being aware of your relationship patterns is a powerful step toward deeper connections.",
                "recommended_next": [
                    {
                        "slide_group_id": "communication-patterns",
                        "collection_id": "dddd4444-dddd-4444-dddd-dddddddd4444",
                        "title": "Communication Patterns",
                        "description": "Explore how you communicate and its impact."
                    },
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Understanding Emotions",
                        "description": "Deepen your emotional awareness for better relationships."
                    }
                ]
            }
        ]
    },
    {
        "id": "communication-patterns",
        "title": "Communication Patterns",
        "description": "Explore how you communicate and how it affects your relationships.",
        "position": 2,
        "slides": [
            {
                "id": "comm-express",
                "type": "journal_prompt",
                "question": "How do I typically express my needs and feelings to others?",
                "config": { "allowAI": true }
            },
            {
                "id": "comm-misunderstood",
                "type": "journal_prompt",
                "question": "What happens when I feel misunderstood or unheard?",
                "config": { "allowAI": true }
            },
            {
                "id": "comm-struggle",
                "type": "journal_prompt",
                "question": "Are there things I struggle to say to people I care about?",
                "config": { "allowAI": true }
            },
            {
                "id": "comm-conflict",
                "type": "journal_prompt",
                "question": "How do I handle conflict in relationships?",
                "config": { "allowAI": true }
            },
            {
                "id": "comm-completion",
                "type": "completion",
                "title": "Patterns noticed",
                "content": "Understanding how you communicate is the first step toward healthier connections.",
                "recommended_next": [
                    {
                        "slide_group_id": "setting-boundaries",
                        "collection_id": "dddd4444-dddd-4444-dddd-dddddddd4444",
                        "title": "Setting Boundaries",
                        "description": "Reflect on your boundaries and how they protect you."
                    }
                ]
            }
        ]
    },
    {
        "id": "setting-boundaries",
        "title": "Setting Boundaries",
        "description": "Reflect on your boundaries and how they protect your well-being.",
        "position": 3,
        "slides": [
            {
                "id": "bound-need",
                "type": "journal_prompt",
                "question": "What boundaries do I need to set or strengthen in my life?",
                "config": { "allowAI": true }
            },
            {
                "id": "bound-crossed",
                "type": "journal_prompt",
                "question": "How do I feel when my boundaries are crossed?",
                "config": { "allowAI": true }
            },
            {
                "id": "bound-no",
                "type": "journal_prompt",
                "question": "What makes it hard for me to say no?",
                "config": { "allowAI": true }
            },
            {
                "id": "bound-communicate",
                "type": "journal_prompt",
                "question": "How can I communicate my boundaries with kindness and clarity?",
                "config": { "allowAI": true }
            },
            {
                "id": "bound-completion",
                "type": "completion",
                "title": "Boundaries explored",
                "content": "Healthy boundaries are an act of self-love and respect — for yourself and others.",
                "recommended_next": [
                    {
                        "slide_group_id": "forgiveness-letting-go",
                        "collection_id": "dddd4444-dddd-4444-dddd-dddddddd4444",
                        "title": "Forgiveness & Letting Go",
                        "description": "Explore forgiveness as a path to freedom."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Self-Compassion",
                        "description": "Be kind to yourself through relationship challenges."
                    }
                ]
            }
        ]
    },
    {
        "id": "forgiveness-letting-go",
        "title": "Forgiveness & Letting Go",
        "description": "Explore forgiveness — both giving it and receiving it.",
        "position": 4,
        "slides": [
            {
                "id": "forgive-resentment",
                "type": "journal_prompt",
                "question": "Is there someone I am holding resentment toward? What happened?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-affect",
                "type": "journal_prompt",
                "question": "How is holding onto this affecting me?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-mean",
                "type": "journal_prompt",
                "question": "What would it mean to forgive — and what would I need to let go?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-self",
                "type": "journal_prompt",
                "question": "Is there something I need to forgive myself for?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-completion",
                "type": "completion",
                "title": "A weight lifted",
                "content": "Forgiveness is not about condoning — it is about freeing yourself.",
                "metric_label": "Relationships collection complete",
                "recommended_next": [
                    {
                        "slide_group_id": "self-forgiveness",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Self-Forgiveness",
                        "description": "Go deeper into forgiving yourself."
                    },
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Daily Gratitude",
                        "description": "Shift focus to appreciation and positivity."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'dddd4444-dddd-4444-dddd-dddddddd4444';


-- ============================================================================
-- Collection 8: Gratitude Practice (eeee5555-...) — journal
-- Adds: completion slides, CTA to Relationships
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "daily-gratitude",
        "title": "Daily Gratitude",
        "description": "A simple daily practice to notice and appreciate the good in your life.",
        "position": 1,
        "slides": [
            {
                "id": "grat-three",
                "type": "journal_prompt",
                "question": "What are three things I am grateful for today?",
                "config": { "allowAI": true }
            },
            {
                "id": "grat-small",
                "type": "journal_prompt",
                "question": "What small moment brought me joy or peace today?",
                "config": { "allowAI": true }
            },
            {
                "id": "grat-person",
                "type": "journal_prompt",
                "question": "Who made a positive difference in my day, and how?",
                "config": { "allowAI": true }
            },
            {
                "id": "grat-completion",
                "type": "completion",
                "title": "Gratitude noted!",
                "content": "Taking time to appreciate the good in your life shifts your perspective over time.",
                "recommended_next": [
                    {
                        "slide_group_id": "appreciating-self",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Appreciating Yourself",
                        "description": "Turn gratitude inward and appreciate your own qualities."
                    },
                    {
                        "slide_group_id": "evening-reflection",
                        "collection_id": "55555555-5555-5555-5555-555555555555",
                        "title": "Evening Reflection",
                        "description": "Continue reflecting on your day."
                    }
                ]
            }
        ]
    },
    {
        "id": "appreciating-self",
        "title": "Appreciating Yourself",
        "description": "Turn gratitude inward and appreciate your own qualities and efforts.",
        "position": 2,
        "slides": [
            {
                "id": "self-appreciate",
                "type": "journal_prompt",
                "question": "What is something I appreciate about myself today?",
                "config": { "allowAI": true }
            },
            {
                "id": "self-challenge",
                "type": "journal_prompt",
                "question": "What challenge did I handle well recently?",
                "config": { "allowAI": true }
            },
            {
                "id": "self-strength",
                "type": "journal_prompt",
                "question": "What strength helped me get through a difficult moment?",
                "config": { "allowAI": true }
            },
            {
                "id": "self-growth",
                "type": "journal_prompt",
                "question": "How have I grown in the past year?",
                "config": { "allowAI": true }
            },
            {
                "id": "self-appreciate-completion",
                "type": "completion",
                "title": "You are worthy of appreciation",
                "content": "Recognizing your own strengths builds resilience and confidence.",
                "recommended_next": [
                    {
                        "slide_group_id": "appreciating-others",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Appreciating Others",
                        "description": "Reflect on the people who enrich your life."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Self-Compassion",
                        "description": "Deepen your self-appreciation with self-compassion."
                    }
                ]
            }
        ]
    },
    {
        "id": "appreciating-others",
        "title": "Appreciating Others",
        "description": "Reflect on the people who enrich your life and consider expressing appreciation.",
        "position": 3,
        "slides": [
            {
                "id": "others-granted",
                "type": "journal_prompt",
                "question": "Who is someone I often take for granted but am truly grateful for?",
                "config": { "allowAI": true }
            },
            {
                "id": "others-done",
                "type": "journal_prompt",
                "question": "What has someone done for me recently that I appreciated?",
                "config": { "allowAI": true }
            },
            {
                "id": "others-express",
                "type": "journal_prompt",
                "question": "How could I express my gratitude to someone this week?",
                "config": { "allowAI": true }
            },
            {
                "id": "others-qualities",
                "type": "journal_prompt",
                "question": "What qualities do I admire in the people closest to me?",
                "config": { "allowAI": true }
            },
            {
                "id": "others-cta-relationships",
                "type": "cta",
                "title": "Want to strengthen your connections?",
                "content": "Explore how your relationships shape your well-being.",
                "config": {
                    "slide_group_id": "relationship-reflection",
                    "collection_id": "dddd4444-dddd-4444-dddd-dddddddd4444"
                }
            },
            {
                "id": "others-completion",
                "type": "completion",
                "title": "Appreciation shared",
                "content": "Gratitude for others strengthens your relationships and brings joy to both of you.",
                "recommended_next": [
                    {
                        "slide_group_id": "silver-linings",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Finding Silver Linings",
                        "description": "Practice gratitude even in difficult situations."
                    }
                ]
            }
        ]
    },
    {
        "id": "silver-linings",
        "title": "Finding Silver Linings",
        "description": "Practice finding gratitude even in difficult situations.",
        "position": 4,
        "slides": [
            {
                "id": "silver-difficult",
                "type": "journal_prompt",
                "question": "What difficult experience taught me something valuable?",
                "config": { "allowAI": true }
            },
            {
                "id": "silver-positive",
                "type": "journal_prompt",
                "question": "Is there anything positive that came from a challenging situation?",
                "config": { "allowAI": true }
            },
            {
                "id": "silver-grow",
                "type": "journal_prompt",
                "question": "How has a struggle helped me grow or become stronger?",
                "config": { "allowAI": true }
            },
            {
                "id": "silver-learning",
                "type": "journal_prompt",
                "question": "What am I learning from my current challenges?",
                "config": { "allowAI": true }
            },
            {
                "id": "silver-completion",
                "type": "completion",
                "title": "Perspective shifted",
                "content": "Finding gratitude in difficulty is a powerful resilience skill. Well done.",
                "metric_label": "Gratitude Practice collection complete",
                "recommended_next": [
                    {
                        "slide_group_id": "what-is-mindfulness",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Mindfulness",
                        "description": "Cultivate present-moment awareness and calm."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Self-Compassion",
                        "description": "Be kind to yourself through challenges."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'eeee5555-eeee-4555-eeee-eeeeeeee5555';


-- ============================================================================
-- Collection 9: Understanding Emotions (ffff6666-...) — learn
-- Adds: questionnaire for emotion identification, completion slides
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "what-are-emotions",
        "title": "What Are Emotions?",
        "description": "Understanding emotions as messengers rather than problems to fix.",
        "position": 1,
        "slides": [
            {
                "id": "emo-messengers",
                "type": "doc",
                "title": "Emotions are messengers",
                "content": "<h3>Emotions are messengers</h3><p>Emotions are not good or bad — they are <strong>information</strong>. They tell us about our needs, boundaries, and what matters to us. Learning to listen to them is key to emotional health.</p>"
            },
            {
                "id": "emo-purpose",
                "type": "doc",
                "title": "The purpose of emotions",
                "content": "<h3>The purpose of emotions</h3><p><strong>Fear</strong> protects us from danger. <strong>Anger</strong> signals a boundary has been crossed. <strong>Sadness</strong> helps us process loss. <strong>Joy</strong> connects us to what we love. Every emotion has a purpose.</p>"
            },
            {
                "id": "emo-temporary",
                "type": "doc",
                "title": "Emotions are temporary",
                "content": "<h3>Emotions are temporary</h3><p>No emotion lasts forever. Like waves, they rise, peak, and fall. Resisting them often makes them stronger; allowing them helps them pass.</p>"
            },
            {
                "id": "emo-identify",
                "type": "questionnaire",
                "question": "What emotion feels most present for you right now?",
                "content": "Choose the one that fits best in this moment.",
                "mode": "single",
                "options": [
                    {"id": "joy", "label": "Joy or contentment", "description": "I feel good, grateful, or at peace"},
                    {"id": "sadness", "label": "Sadness", "description": "I feel heavy, low, or grieving"},
                    {"id": "anxiety", "label": "Anxiety or worry", "description": "I feel tense, on edge, or fearful"},
                    {"id": "anger", "label": "Anger or frustration", "description": "I feel irritated, upset, or resentful"},
                    {"id": "numb", "label": "Numb or disconnected", "description": "I do not feel much of anything"},
                    {"id": "confused", "label": "Confused", "description": "I am not sure what I am feeling"}
                ]
            },
            {
                "id": "emo-what-completion",
                "type": "completion",
                "title": "Emotions understood",
                "content": "Every emotion is valid and temporary. The more you listen, the better you understand yourself.",
                "metric_label": "Lesson complete",
                "recommended_next": [
                    {
                        "slide_group_id": "emotional-awareness",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Building Emotional Awareness",
                        "description": "Learn to notice and name emotions with precision."
                    }
                ]
            }
        ]
    },
    {
        "id": "emotional-awareness",
        "title": "Building Emotional Awareness",
        "description": "Learn to notice and name your emotions with greater precision.",
        "position": 2,
        "slides": [
            {
                "id": "aware-name",
                "type": "doc",
                "title": "Name it to tame it",
                "content": "<h3>Name it to tame it</h3><p>Research shows that simply <strong>naming an emotion</strong> can reduce its intensity. Instead of 'I feel bad,' try to get specific: 'I feel disappointed and a little anxious.'</p>"
            },
            {
                "id": "aware-body",
                "type": "doc",
                "title": "Emotions in the body",
                "content": "<h3>Emotions in the body</h3><p>Emotions show up physically. Anxiety might feel like a tight chest. Sadness might feel heavy. Anger might feel hot. Notice where you feel emotions in your body.</p>"
            },
            {
                "id": "aware-current",
                "type": "journal_prompt",
                "question": "What emotion am I feeling right now? Where do I feel it in my body?",
                "config": { "allowAI": true }
            },
            {
                "id": "aware-telling",
                "type": "journal_prompt",
                "question": "What is this emotion trying to tell me?",
                "config": { "allowAI": true }
            },
            {
                "id": "aware-completion",
                "type": "completion",
                "title": "Awareness deepened",
                "content": "Naming emotions precisely is a skill that grows with practice.",
                "recommended_next": [
                    {
                        "slide_group_id": "difficult-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Working with Difficult Emotions",
                        "description": "Strategies for sitting with uncomfortable feelings."
                    }
                ]
            }
        ]
    },
    {
        "id": "difficult-emotions",
        "title": "Working with Difficult Emotions",
        "description": "Strategies for sitting with uncomfortable emotions without being overwhelmed.",
        "position": 3,
        "slides": [
            {
                "id": "diff-dont-fight",
                "type": "doc",
                "title": "Don't fight, don't follow",
                "content": "<h3>Don't fight, don't follow</h3><p>When a difficult emotion arises, don't try to push it away (fight) or get lost in the story (follow). Instead, <strong>acknowledge it</strong>: 'I notice I am feeling anxious right now.'</p>"
            },
            {
                "id": "diff-rain",
                "type": "doc",
                "title": "RAIN technique",
                "content": "<h3>RAIN technique</h3><p><strong>R</strong>ecognize what is happening. <strong>A</strong>llow the experience to be there. <strong>I</strong>nvestigate with kindness. <strong>N</strong>urture yourself with self-compassion.</p>"
            },
            {
                "id": "diff-avoiding",
                "type": "journal_prompt",
                "question": "What difficult emotion have I been avoiding lately?",
                "config": { "allowAI": true }
            },
            {
                "id": "diff-support",
                "type": "journal_prompt",
                "question": "What do I need right now to support myself through this feeling?",
                "config": { "allowAI": true }
            },
            {
                "id": "diff-completion",
                "type": "completion",
                "title": "Courage recognized",
                "content": "Facing difficult emotions takes courage. You are building emotional resilience.",
                "recommended_next": [
                    {
                        "slide_group_id": "emotional-triggers",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Understanding Triggers",
                        "description": "Explore what triggers strong emotional reactions."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Self-Compassion",
                        "description": "Be kind to yourself through difficult emotions."
                    }
                ]
            }
        ]
    },
    {
        "id": "emotional-triggers",
        "title": "Understanding Triggers",
        "description": "Explore what triggers strong emotional reactions and why.",
        "position": 4,
        "slides": [
            {
                "id": "trigger-what",
                "type": "doc",
                "title": "What is an emotional trigger?",
                "content": "<h3>What is an emotional trigger?</h3><p>A trigger is something that sets off a strong emotional reaction — often connected to past experiences. Understanding your triggers helps you respond rather than react.</p>"
            },
            {
                "id": "trigger-situations",
                "type": "journal_prompt",
                "question": "What situations tend to trigger strong emotions in me?",
                "config": { "allowAI": true }
            },
            {
                "id": "trigger-react",
                "type": "journal_prompt",
                "question": "When I am triggered, how do I typically react?",
                "config": { "allowAI": true }
            },
            {
                "id": "trigger-past",
                "type": "journal_prompt",
                "question": "What past experience might this trigger be connected to?",
                "config": { "allowAI": true }
            },
            {
                "id": "trigger-respond",
                "type": "journal_prompt",
                "question": "How could I respond differently next time I am triggered?",
                "config": { "allowAI": true }
            },
            {
                "id": "trigger-completion",
                "type": "completion",
                "title": "Self-knowledge gained",
                "content": "Understanding your triggers is a powerful step toward emotional freedom.",
                "metric_label": "Understanding Emotions complete",
                "recommended_next": [
                    {
                        "slide_group_id": "what-is-mindfulness",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Mindfulness",
                        "description": "Learn to observe emotions without reacting."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Self-Compassion",
                        "description": "Meet yourself with kindness through emotional storms."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'ffff6666-ffff-4666-ffff-ffffffff6666';


-- ============================================================================
-- Collection 10: Mindfulness (a0a07777-...) — learn
-- Adds: questionnaire for experience level, completion slides, CTA to Anxiety
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "what-is-mindfulness",
        "title": "What is Mindfulness?",
        "description": "Understanding mindfulness and why it matters for mental health.",
        "position": 1,
        "slides": [
            {
                "id": "mind-defined",
                "type": "doc",
                "title": "Mindfulness defined",
                "content": "<h3>Mindfulness defined</h3><p>Mindfulness is <strong>paying attention to the present moment, on purpose, without judgment</strong>. It is about noticing what is happening right now — your thoughts, feelings, and sensations — with curiosity rather than criticism.</p>"
            },
            {
                "id": "mind-why",
                "type": "doc",
                "title": "Why mindfulness helps",
                "content": "<h3>Why mindfulness helps</h3><p>When we are caught up in worries about the future or regrets about the past, we suffer. Mindfulness brings us back to the only moment we can actually live in — <strong>now</strong>.</p>"
            },
            {
                "id": "mind-skill",
                "type": "doc",
                "title": "Mindfulness is a skill",
                "content": "<h3>Mindfulness is a skill</h3><p>Like any skill, mindfulness improves with practice. You do not need to be perfect at it. The goal is not to empty your mind — it is to notice when your mind wanders and gently bring it back.</p>"
            },
            {
                "id": "mind-experience-check",
                "type": "questionnaire",
                "question": "What is your experience with mindfulness?",
                "content": "This helps us understand where you are starting from.",
                "mode": "single",
                "options": [
                    {"id": "new", "label": "Completely new", "description": "I have never tried mindfulness before"},
                    {"id": "curious", "label": "Curious beginner", "description": "I have heard about it but rarely practice"},
                    {"id": "occasional", "label": "Occasional practice", "description": "I try to be mindful sometimes"},
                    {"id": "regular", "label": "Regular practice", "description": "I practice mindfulness regularly"}
                ]
            },
            {
                "id": "mind-what-completion",
                "type": "completion",
                "title": "Journey started",
                "content": "No matter where you are starting from, mindfulness can benefit you.",
                "metric_label": "Lesson complete",
                "recommended_next": [
                    {
                        "slide_group_id": "mindful-breathing",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Mindful Breathing",
                        "description": "A simple practice using breath as your anchor."
                    }
                ]
            }
        ]
    },
    {
        "id": "mindful-breathing",
        "title": "Mindful Breathing",
        "description": "A simple practice using your breath as an anchor to the present moment.",
        "position": 2,
        "slides": [
            {
                "id": "breath-anchor",
                "type": "doc",
                "title": "Your breath is always with you",
                "content": "<h3>Your breath is always with you</h3><p>Your breath is a powerful anchor to the present. It is always happening now, making it the perfect focus for mindfulness practice.</p>"
            },
            {
                "id": "breath-how",
                "type": "doc",
                "title": "How to practice",
                "content": "<h3>How to practice</h3><p>Sit comfortably and close your eyes. Notice your breath — the inhale, the exhale, the pause between. When thoughts arise, acknowledge them and gently return to the breath.</p>"
            },
            {
                "id": "breath-small",
                "type": "doc",
                "title": "Start small",
                "content": "<h3>Start small</h3><p>Even 1-2 minutes of mindful breathing can make a difference. Start small and build up. Consistency matters more than duration.</p>"
            },
            {
                "id": "breath-completion",
                "type": "completion",
                "title": "Breath anchored",
                "content": "You now have a tool you can use anytime, anywhere. Just breathe.",
                "recommended_next": [
                    {
                        "slide_group_id": "body-scan",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Body Scan Practice",
                        "description": "Connect with physical sensations and release tension."
                    }
                ]
            }
        ]
    },
    {
        "id": "body-scan",
        "title": "Body Scan Practice",
        "description": "A guided practice to connect with physical sensations and release tension.",
        "position": 3,
        "slides": [
            {
                "id": "scan-what",
                "type": "doc",
                "title": "What is a body scan?",
                "content": "<h3>What is a body scan?</h3><p>A body scan is a mindfulness practice where you slowly move your attention through different parts of your body, noticing sensations without trying to change them.</p>"
            },
            {
                "id": "scan-how",
                "type": "doc",
                "title": "How to practice",
                "content": "<h3>How to practice</h3><p>Lie down or sit comfortably. Start at the top of your head and slowly move your attention down through your body — face, neck, shoulders, arms, chest, belly, legs, feet. Notice what you feel.</p>"
            },
            {
                "id": "scan-benefits",
                "type": "doc",
                "title": "Benefits of body scanning",
                "content": "<h3>Benefits of body scanning</h3><p>Body scans help you notice where you hold tension, reconnect with your body, and calm your nervous system. They are especially helpful before sleep or during stressful moments.</p>"
            },
            {
                "id": "scan-cta-anxiety",
                "type": "cta",
                "title": "Using body scan for anxiety?",
                "content": "Learn more grounding techniques specifically for anxious moments.",
                "config": {
                    "slide_group_id": "grounding-techniques",
                    "collection_id": "bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222"
                }
            },
            {
                "id": "scan-completion",
                "type": "completion",
                "title": "Body awareness deepened",
                "content": "Regular body scans help you stay connected to your physical experience.",
                "recommended_next": [
                    {
                        "slide_group_id": "mindful-moments",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Mindful Moments",
                        "description": "Practice mindfulness through reflective journaling."
                    }
                ]
            }
        ]
    },
    {
        "id": "mindful-moments",
        "title": "Mindful Moments",
        "description": "Journal prompts to practice mindfulness through reflection.",
        "position": 4,
        "slides": [
            {
                "id": "moment-notice",
                "type": "journal_prompt",
                "question": "What am I noticing right now — thoughts, feelings, sensations?",
                "config": { "allowAI": true }
            },
            {
                "id": "moment-sounds",
                "type": "journal_prompt",
                "question": "What sounds can I hear in this moment?",
                "config": { "allowAI": true }
            },
            {
                "id": "moment-tension",
                "type": "journal_prompt",
                "question": "Where in my body do I feel tension, and can I soften around it?",
                "config": { "allowAI": true }
            },
            {
                "id": "moment-appreciate",
                "type": "journal_prompt",
                "question": "What is one thing I can appreciate about this present moment?",
                "config": { "allowAI": true }
            },
            {
                "id": "moment-rating",
                "type": "star_rating",
                "question": "How present did you feel during this practice?",
                "config": { "min": 1, "max": 5 }
            },
            {
                "id": "moment-completion",
                "type": "completion",
                "title": "Present moment lived",
                "content": "Every mindful moment strengthens your ability to stay present.",
                "metric_label": "Mindfulness collection complete",
                "recommended_next": [
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Understanding Emotions",
                        "description": "Combine mindfulness with emotional awareness."
                    },
                    {
                        "slide_group_id": "what-is-self-compassion",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Self-Compassion",
                        "description": "Add compassion to your mindfulness practice."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'a0a07777-a0a0-4777-a0a0-a0a0a0a07777';


-- ============================================================================
-- Collection 11: Self-Compassion (b0b08888-...) — learn
-- Adds: star_rating, completion slides
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "what-is-self-compassion",
        "title": "What is Self-Compassion?",
        "description": "Understanding self-compassion and why it is different from self-esteem.",
        "position": 1,
        "slides": [
            {
                "id": "comp-defined",
                "type": "doc",
                "title": "Self-compassion defined",
                "content": "<h3>Self-compassion defined</h3><p>Self-compassion means treating yourself with the same <strong>kindness, understanding, and patience</strong> you would offer a good friend who is struggling.</p>"
            },
            {
                "id": "comp-elements",
                "type": "doc",
                "title": "Three elements of self-compassion",
                "content": "<h3>Three elements of self-compassion</h3><p><strong>1. Self-kindness</strong> instead of self-judgment. <strong>2. Common humanity</strong> — recognizing that suffering is part of being human. <strong>3. Mindfulness</strong> — holding painful feelings in balanced awareness.</p>"
            },
            {
                "id": "comp-vs-esteem",
                "type": "doc",
                "title": "Self-compassion vs. self-esteem",
                "content": "<h3>Self-compassion vs. self-esteem</h3><p>Self-esteem is about evaluating yourself positively. Self-compassion is about <strong>being kind to yourself regardless of success or failure</strong>. It is more stable and unconditional.</p>"
            },
            {
                "id": "comp-what-completion",
                "type": "completion",
                "title": "Kindness begins within",
                "content": "Understanding self-compassion opens the door to a gentler relationship with yourself.",
                "metric_label": "Lesson complete",
                "recommended_next": [
                    {
                        "slide_group_id": "inner-critic",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Working with the Inner Critic",
                        "description": "Learn to recognize and soften your harsh inner voice."
                    }
                ]
            }
        ]
    },
    {
        "id": "inner-critic",
        "title": "Working with the Inner Critic",
        "description": "Learn to recognize and soften your harsh inner voice.",
        "position": 2,
        "slides": [
            {
                "id": "critic-what",
                "type": "doc",
                "title": "The inner critic",
                "content": "<h3>The inner critic</h3><p>Many of us have an inner voice that criticizes, judges, and puts us down. This voice often developed to protect us, but it can become harsh and harmful.</p>"
            },
            {
                "id": "critic-notice",
                "type": "doc",
                "title": "Noticing the critic",
                "content": "<h3>Noticing the critic</h3><p>The first step is to <strong>notice</strong> when your inner critic is speaking. What does it say? What tone does it use? Would you speak this way to a friend?</p>"
            },
            {
                "id": "critic-says",
                "type": "journal_prompt",
                "question": "What does my inner critic typically say to me?",
                "config": { "allowAI": true }
            },
            {
                "id": "critic-friend",
                "type": "journal_prompt",
                "question": "What would a compassionate friend say instead?",
                "config": { "allowAI": true }
            },
            {
                "id": "critic-completion",
                "type": "completion",
                "title": "Inner voice noticed",
                "content": "Awareness of your inner critic is the first step to changing the conversation.",
                "recommended_next": [
                    {
                        "slide_group_id": "self-compassion-practice",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Self-Compassion Practice",
                        "description": "A simple exercise for cultivating kindness."
                    }
                ]
            }
        ]
    },
    {
        "id": "self-compassion-practice",
        "title": "Self-Compassion Practice",
        "description": "A simple exercise to cultivate self-compassion in difficult moments.",
        "position": 3,
        "slides": [
            {
                "id": "practice-break",
                "type": "doc",
                "title": "The self-compassion break",
                "content": "<h3>The self-compassion break</h3><p>When you are struggling, try these three phrases: <strong>1.</strong> 'This is a moment of suffering.' <strong>2.</strong> 'Suffering is part of life.' <strong>3.</strong> 'May I be kind to myself.'</p>"
            },
            {
                "id": "practice-physical",
                "type": "doc",
                "title": "Physical self-compassion",
                "content": "<h3>Physical self-compassion</h3><p>Place your hand on your heart or give yourself a gentle hug. Physical touch releases oxytocin and can soothe your nervous system.</p>"
            },
            {
                "id": "practice-kind",
                "type": "journal_prompt",
                "question": "What is one kind thing I can do for myself today?",
                "config": { "allowAI": true }
            },
            {
                "id": "practice-gentle",
                "type": "journal_prompt",
                "question": "How can I be gentler with myself this week?",
                "config": { "allowAI": true }
            },
            {
                "id": "practice-kindness-rating",
                "type": "star_rating",
                "question": "How kind have you been to yourself today?",
                "config": { "min": 1, "max": 5 }
            },
            {
                "id": "practice-completion",
                "type": "completion",
                "title": "Kindness practiced",
                "content": "Self-compassion is a practice, not a destination. Every small act of kindness toward yourself counts.",
                "recommended_next": [
                    {
                        "slide_group_id": "self-forgiveness",
                        "collection_id": "b0b08888-b0b0-4888-b0b0-b0b0b0b08888",
                        "title": "Self-Forgiveness",
                        "description": "Release guilt and shame through self-forgiveness."
                    },
                    {
                        "slide_group_id": "what-is-mindfulness",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Mindfulness",
                        "description": "Combine mindfulness with self-compassion."
                    }
                ]
            }
        ]
    },
    {
        "id": "self-forgiveness",
        "title": "Self-Forgiveness",
        "description": "Learn to release guilt and shame through self-forgiveness.",
        "position": 4,
        "slides": [
            {
                "id": "forgive-why",
                "type": "doc",
                "title": "Why self-forgiveness matters",
                "content": "<h3>Why self-forgiveness matters</h3><p>Holding onto guilt and shame keeps us stuck. Self-forgiveness does not mean excusing harmful behavior — it means <strong>releasing the burden</strong> so you can move forward and do better.</p>"
            },
            {
                "id": "forgive-holding",
                "type": "journal_prompt",
                "question": "What am I still holding against myself?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-mean",
                "type": "journal_prompt",
                "question": "What would it mean to truly forgive myself for this?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-learned",
                "type": "journal_prompt",
                "question": "What have I learned from this experience?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-amends",
                "type": "journal_prompt",
                "question": "How can I make amends — to myself or others — and move forward?",
                "config": { "allowAI": true }
            },
            {
                "id": "forgive-completion",
                "type": "completion",
                "title": "Freedom chosen",
                "content": "Self-forgiveness is an act of courage and self-love. You deserve to move forward.",
                "metric_label": "Self-Compassion collection complete",
                "recommended_next": [
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Daily Gratitude",
                        "description": "Shift your focus toward appreciation."
                    },
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Understanding Emotions",
                        "description": "Deepen your emotional self-awareness."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = 'b0b08888-b0b0-4888-b0b0-b0b0b0b08888';


-- ============================================================================
-- Collection 12: Check-Ins (66666666-...) — journal
-- Adds: sleep_check in daily, completion slides
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "daily-checkin",
        "title": "Daily Check-In",
        "description": "Quick prompts to check in with yourself each day and notice your state of mind.",
        "position": 1,
        "slides": [
            {
                "id": "daily-mood",
                "type": "emotion_log",
                "question": "How am I feeling today?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Storm", "Heavy Rain", "Rain", "Cloudy", "Partly Cloudy", "Mostly Sunny", "Sunny", "Bright", "Radiant", "Blissful"]
                }
            },
            {
                "id": "daily-energy",
                "type": "sleep_check",
                "question": "How is your energy level right now?",
                "config": { "min": 0, "max": 100 }
            },
            {
                "id": "daily-feeling",
                "type": "journal_prompt",
                "question": "How am I feeling today?",
                "config": { "allowAI": true }
            },
            {
                "id": "daily-obstacles",
                "type": "journal_prompt",
                "question": "What obstacles am I facing?",
                "config": { "allowAI": true }
            },
            {
                "id": "daily-learning",
                "type": "journal_prompt",
                "question": "What am I learning from these obstacles?",
                "config": { "allowAI": true }
            },
            {
                "id": "daily-notes",
                "type": "journal_prompt",
                "question": "Notes/Reflection",
                "config": { "allowAI": true }
            },
            {
                "id": "daily-checkin-completion",
                "type": "completion",
                "title": "Checked in!",
                "content": "Daily awareness builds over time. Keep showing up for yourself.",
                "recommended_next": [
                    {
                        "slide_group_id": "emotional-checkin",
                        "collection_id": "66666666-6666-4666-6666-666666666666",
                        "title": "Emotional Check-In",
                        "description": "Go deeper into your emotional state."
                    },
                    {
                        "slide_group_id": "daily-gratitude",
                        "collection_id": "eeee5555-eeee-4555-eeee-eeeeeeee5555",
                        "title": "Daily Gratitude",
                        "description": "Add gratitude to your daily practice."
                    }
                ]
            }
        ]
    },
    {
        "id": "emotional-checkin",
        "title": "Emotional Check-In",
        "description": "Reflect on your emotions to understand triggers, responses, and ways to support yourself.",
        "position": 2,
        "slides": [
            {
                "id": "emo-current-mood",
                "type": "emotion_log",
                "question": "How intense is whatever you are feeling right now?",
                "config": {
                    "scale": "1-10",
                    "labels": ["Barely There", "Faint", "Mild", "Noticeable", "Moderate", "Strong", "Very Strong", "Intense", "Overwhelming", "All-Consuming"]
                }
            },
            {
                "id": "emo-feeling",
                "type": "journal_prompt",
                "question": "What emotion am I feeling now?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-trigger",
                "type": "journal_prompt",
                "question": "What might have triggered this emotion?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-respond",
                "type": "journal_prompt",
                "question": "How am I responding to this emotion?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-last",
                "type": "journal_prompt",
                "question": "When was the last time I felt this way?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-affect",
                "type": "journal_prompt",
                "question": "How does this emotion affect my thoughts and behavior?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-learn",
                "type": "journal_prompt",
                "question": "What can I learn from this emotion?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-support",
                "type": "journal_prompt",
                "question": "How can I support myself through this emotion?",
                "config": { "allowAI": true }
            },
            {
                "id": "emo-checkin-completion",
                "type": "completion",
                "title": "Emotional awareness deepened",
                "content": "Every time you check in with your emotions, you build self-understanding.",
                "recommended_next": [
                    {
                        "slide_group_id": "what-are-emotions",
                        "collection_id": "ffff6666-ffff-4666-ffff-ffffffff6666",
                        "title": "Understanding Emotions",
                        "description": "Learn more about the purpose of emotions."
                    },
                    {
                        "slide_group_id": "what-is-mindfulness",
                        "collection_id": "a0a07777-a0a0-4777-a0a0-a0a0a0a07777",
                        "title": "Mindfulness",
                        "description": "Observe your emotions with mindful awareness."
                    }
                ]
            }
        ]
    }
]$$::jsonb
WHERE id = '66666666-6666-4666-6666-666666666666';
