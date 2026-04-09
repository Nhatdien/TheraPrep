-- Down Migration 000028: Revert slide_groups to original values from 000017/000018
-- Restores all 12 collections to their pre-enrichment state

-- ============================================================================
-- Collection 1: Daily Reflection (from 000017)
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
                "id": "evening-memorable",
                "type": "journal_prompt",
                "question": "What happened today worth remembering?",
                "config": { "allowAI": true }
            },
            {
                "id": "evening-positive",
                "type": "journal_prompt",
                "question": "What went well today?",
                "config": { "allowAI": true }
            },
            {
                "id": "evening-learning",
                "type": "journal_prompt",
                "question": "What did I learn today?",
                "config": { "allowAI": true }
            },
            {
                "id": "evening-changes",
                "type": "journal_prompt",
                "question": "What would I have changed about today?",
                "config": { "allowAI": true }
            },
            {
                "id": "evening-celebrate",
                "type": "journal_prompt",
                "question": "What can I celebrate today?",
                "config": { "allowAI": true }
            },
            {
                "id": "evening-growth",
                "type": "journal_prompt",
                "question": "How am I different from yesterday?",
                "config": { "allowAI": true }
            },
            {
                "id": "evening-winddown",
                "type": "journal_prompt",
                "question": "How can I wind down, release the day, and rest now?",
                "config": { "allowAI": true }
            }
        ]
    }
]$$::jsonb
WHERE id = '55555555-5555-5555-5555-555555555555';


-- ============================================================================
-- Collection 2: Therapy Preparation (from 000017)
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
                "id": "sign-reminder",
                "type": "doc",
                "title": "A reminder",
                "content": "<h3>A reminder</h3><p>These are just common signs — you don't need to have any of them to see a therapist. All you need is the desire to feel better and share what is on your chest.</p>"
            },
            {
                "id": "therapy-reflection",
                "type": "journal_prompt",
                "question": "After reading these signs, what resonates with you? What are you feeling right now?",
                "config": {
                    "allowAI": true,
                    "minLength": 30
                }
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
                "config": { "allowAI": true }
            },
            {
                "id": "therapist-struggles",
                "type": "journal_prompt",
                "question": "What has been most difficult for you lately?",
                "config": { "allowAI": true }
            },
            {
                "id": "therapist-support",
                "type": "journal_prompt",
                "question": "What kind of support do you think would be most helpful?",
                "config": { "allowAI": true }
            }
        ]
    }
]$$::jsonb
WHERE id = '33333333-3333-3333-3333-333333333333';


-- ============================================================================
-- Collection 3: Stress Management (from 000017)
-- ============================================================================
UPDATE journal_templates SET slide_groups = $$[
    {
        "id": "stress-check-in",
        "title": "Stress Check-In",
        "description": "Assess your current stress level and identify triggers.",
        "position": 1,
        "slides": [
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
                "config": { "allowAI": true }
            },
            {
                "id": "stress-coping",
                "type": "journal_prompt",
                "question": "What has helped you cope with stress in the past?",
                "config": { "allowAI": true }
            },
            {
                "id": "stress-action",
                "type": "journal_prompt",
                "question": "What is one small thing you can do today to reduce your stress?",
                "config": { "allowAI": true }
            }
        ]
    }
]$$::jsonb
WHERE id = '44444444-4444-4444-4444-444444444444';


-- ============================================================================
-- Collection 4: Introduction to Journaling (from 000018)
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
                "config": { "allowAI": true }
            }
        ]
    }
]$$::jsonb
WHERE id = '22222222-2222-2222-2222-222222222222';


-- ============================================================================
-- Collection 5: Understanding Anxiety (from 000018)
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
                "config": { "allowAI": true }
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
                "config": { "allowAI": true }
            },
            {
                "id": "thoughts-evidence",
                "type": "journal_prompt",
                "question": "What evidence do I have that this thought might not be completely true?",
                "config": { "allowAI": true }
            }
        ]
    }
]$$::jsonb
WHERE id = 'bbbb2222-bbbb-4222-bbbb-bbbbbbbb2222';


-- ============================================================================
-- Collection 6: Better Sleep (from 000018)
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
                "id": "hygiene-routine-reflect",
                "type": "journal_prompt",
                "question": "What does my current bedtime routine look like?",
                "config": { "allowAI": true }
            },
            {
                "id": "hygiene-change",
                "type": "journal_prompt",
                "question": "What one change could I make to improve my sleep environment?",
                "config": { "allowAI": true }
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
                "id": "sleep-grateful",
                "type": "journal_prompt",
                "question": "What are three things I am grateful for from today?",
                "config": { "allowAI": true }
            },
            {
                "id": "sleep-letgo",
                "type": "journal_prompt",
                "question": "What can I let go of from today?",
                "config": { "allowAI": true }
            },
            {
                "id": "sleep-onmind",
                "type": "journal_prompt",
                "question": "What thoughts are still on my mind that I can write down and release?",
                "config": { "allowAI": true }
            },
            {
                "id": "sleep-tomorrow",
                "type": "journal_prompt",
                "question": "How do I want to feel when I wake up tomorrow?",
                "config": { "allowAI": true }
            }
        ]
    }
]$$::jsonb
WHERE id = 'cccc3333-cccc-4333-cccc-cccccccc3333';


-- ============================================================================
-- Collection 7: Relationships & Connection (from 000018)
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
            }
        ]
    }
]$$::jsonb
WHERE id = 'dddd4444-dddd-4444-dddd-dddddddd4444';


-- ============================================================================
-- Collection 8: Gratitude Practice (from 000018)
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
            }
        ]
    }
]$$::jsonb
WHERE id = 'eeee5555-eeee-4555-eeee-eeeeeeee5555';


-- ============================================================================
-- Collection 9: Understanding Emotions (from 000018)
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
            }
        ]
    }
]$$::jsonb
WHERE id = 'ffff6666-ffff-4666-ffff-ffffffff6666';


-- ============================================================================
-- Collection 10: Mindfulness (from 000018)
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
                "content": "<h3>Mindfulness is a skill</h3><p>Like any skill, mindfulness improves with practice. You don't need to be perfect at it. The goal isn't to empty your mind — it's to notice when your mind wanders and gently bring it back.</p>"
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
            }
        ]
    }
]$$::jsonb
WHERE id = 'a0a07777-a0a0-4777-a0a0-a0a0a0a07777';


-- ============================================================================
-- Collection 11: Self-Compassion (from 000018)
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
            }
        ]
    }
]$$::jsonb
WHERE id = 'b0b08888-b0b0-4888-b0b0-b0b0b0b08888';


-- ============================================================================
-- Collection 12: Check-Ins (from 000018)
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
            }
        ]
    }
]$$::jsonb
WHERE id = '66666666-6666-4666-6666-666666666666';
