// Shared configuration for all k6 stress test scripts
// Contains base URL, test data, and common functions

import http from 'k6/http';
import { check } from 'k6';

export const BASE_URL = __ENV.AI_SERVICE_URL || 'http://localhost:8000';

// Test data: 50 users covering all scenarios and directions
// 20 users WITH RAG data (already seeded in Qdrant)
// 15 users WITHOUT RAG data (no past history)
// 5 users with CRISIS content (test crisis detection)
// 5 users with VIETNAMESE content (test multilingual)
// 5 additional mixed users

export const TEST_USERS = [
  // === RAG Users (20) - have past journals in Qdrant ===
  // Direction: why (4 users)
  { user_id: "rag-user-001-a1b2c3d4-e5f6-7890-abcd-ef1234567890", content: "I've been having trouble sleeping because of work deadlines. My mind races at night thinking about everything I need to do tomorrow. The insomnia is getting worse.", mood_score: 3, direction: "why", app_language: "en" },
  { user_id: "rag-user-003-c1c2c3c4-d5d6-e7e8-f9f0-a1a2a3a4a5a6", content: "Dad had another health scare today. He seemed fine but then got dizzy. I'm worried about him and feel guilty for not visiting more often.", mood_score: 2, direction: "why", app_language: "en" },
  { user_id: "rag-user-006-1111-2222-3333-4444-555566667777", content: "Sáng nay sếp lại giao thêm task. Tôi đã thử nói không nhưng không được. Cảm giác như mình đang chìm trong công việc.", mood_score: 2, direction: "why", app_language: "en" },
  { user_id: "rag-user-015-9c9c-0d0d-1e1e-2f2f-3a3a4b4b5c5c", content: "I think I'm burnt out. I can't focus on anything and I dread Monday mornings. Even things I used to enjoy feel like chores now.", mood_score: 2, direction: "why", app_language: "en" },

  // Direction: emotions (4 users)
  { user_id: "rag-user-002-f1e2d3c4-b5a6-9876-5432-10fedcba0987", content: "Had another argument with Sarah today. She said I always make everything about myself. I felt defensive but maybe she's right.", mood_score: 2, direction: "emotions", app_language: "en" },
  { user_id: "rag-user-008-2222-3333-4444-5555-666677778889", content: "Went to a party tonight. Everyone was having fun but I felt completely out of place. Smiled and made small talk but inside I felt hollow.", mood_score: 2, direction: "emotions", app_language: "en" },
  { user_id: "rag-user-004-b1b2b3b4-c5c6-d7d8-e9e0-f1f2f3f4f5f6", content: "Something clicked in therapy today. My therapist asked me to describe where I feel emotions in my body. I almost cried for the first time in years.", mood_score: 7, direction: "emotions", app_language: "en" },
  { user_id: "rag-user-017-3e3e-4f4f-5a5a-6b6b-7c7c8d8d9e9e", content: "Ba tháng sau chia tay vẫn thấy buồn mỗi đêm. Đang cố gắng sống tiếp nhưng mọi thứ nhạt nhẽo. Cảm giác bị kẹt trong vòng lặp.", mood_score: 2, direction: "emotions", app_language: "vi" },

  // Direction: patterns (4 users)
  { user_id: "rag-user-005-e1e2e3e4-f5f6-a7a8-b9b0-c1c2c3c4c5c6", content: "My partner and I keep having the same conversation about distance. We don't fight but we also don't really talk anymore. It's like living with a roommate.", mood_score: 3, direction: "patterns", app_language: "en" },
  { user_id: "rag-user-007-8888-9999-aaaa-bbbb-ccddeeff0011", content: "Rest day from the gym and I feel anxious. I realized I use exercise to avoid dealing with my thoughts. When I'm not physically exhausted, my mind goes places I don't want.", mood_score: 4, direction: "patterns", app_language: "en" },
  { user_id: "rag-user-016-6d6d-7e7e-8f8f-9a9a-0b0b1c1c2d2d", content: "I spent 4 hours on an email today because it had to be perfect. Meanwhile my actual work is piling up. I know this is irrational but I can't stop.", mood_score: 3, direction: "patterns", app_language: "en" },
  { user_id: "rag-user-013-5a5a-6b6b-7c7c-8d8d-9e9e0f0f1a1a", content: "Checked my bank account and it's worse than I thought. I keep spending to feel better about being stressed about money. It's a vicious cycle.", mood_score: 2, direction: "patterns", app_language: "en" },

  // Direction: challenge (4 users)
  { user_id: "rag-user-009-aaab-bbcc-ccdd-ddee-eeff00112233", content: "I haven't painted in weeks. Every time I sit at the canvas, nothing comes. I'm afraid I've lost the one thing that made me feel like me.", mood_score: 3, direction: "challenge", app_language: "en" },
  { user_id: "rag-user-011-1122-3344-5566-7788-99aabbccdde0", content: "Got promoted today. Instead of celebrating, I'm terrified. What if they realize I'm not as competent as they think? I've been faking confidence for so long.", mood_score: 4, direction: "challenge", app_language: "en" },
  { user_id: "rag-user-019-b7b7-c8c8-d9d9-e0e0-f1f1a2a2b3b3", content: "Lost my temper with my kid today over something small. They looked scared. In moments of stress, my parents' patterns come out of my mouth.", mood_score: 2, direction: "challenge", app_language: "en" },
  { user_id: "rag-user-014-2b2b-3c3c-4d4d-5e5e-6f6f7a7a8b8b", content: "It's been a year since Grandma passed and grief hit me out of nowhere at the grocery store. I saw someone who looked like her and broke down completely.", mood_score: 1, direction: "challenge", app_language: "en" },

  // Direction: growth (4 users)
  { user_id: "rag-user-010-dede-fefe-0a0a-1b1b-2c2c3d3d4e4e", content: "Đăng ký khóa học design online. Không biết nó dẫn đi đâu nhưng ít nhất đang làm gì đó thay vì chỉ nghĩ. Cảm giác có hướng đi cũng tốt hơn đứng yên.", mood_score: 7, direction: "growth", app_language: "vi" },
  { user_id: "rag-user-012-ff00-ee11-dd22-cc33-bb44aa556677", content: "Joined a running club in my new city. Everyone was welcoming and we grabbed beers after. Made me realize I've been isolating myself. New city, new start.", mood_score: 8, direction: "growth", app_language: "en" },
  { user_id: "rag-user-018-a0a0-b1b1-c2c2-d3d3-e4e4f5f5a6a6", content: "Two weeks into my morning routine and it's becoming automatic. My anxiety is noticeably lower on days I meditate. Grateful I gave myself permission to try.", mood_score: 8, direction: "growth", app_language: "en" },
  { user_id: "rag-user-020-c4c4-d5d5-e6e6-f7f7-a8a8b9b9c0c0", content: "Hôm nay quyết định xin chuyển bộ phận. Đã suy nghĩ 3 tháng rồi. Hồi hộp nhưng cảm giác tự do. Đã lâu rồi mới có cảm giác này.", mood_score: 6, direction: "growth", app_language: "vi" },

  // === No-RAG Users (15) - no past history ===
  { user_id: "norag-user-001-1111-2222-3333-444455556666", content: "I've been feeling overwhelmed with work lately. My manager keeps giving me more tasks and I don't know how to say no. I feel trapped in this cycle.", mood_score: 3, direction: "why", app_language: "en" },
  { user_id: "norag-user-002-aaaa-bbbb-cccc-dddd-eeeeeeeeeeee", content: "Today was actually a good day. But even during good moments, there's a voice telling me it won't last. I'm afraid of being happy because it always crashes down.", mood_score: 7, direction: "emotions", app_language: "en" },
  { user_id: "norag-user-003-5555-6666-7777-8888-99990000aaaa", content: "I've been snapping at everyone lately. My partner, my colleagues, even the barista. I think I'm carrying anger from something deeper I haven't addressed.", mood_score: 3, direction: "why", app_language: "en" },
  { user_id: "norag-user-004-cccc-dddd-eeee-ffff-000011112222", content: "Every time I feel sad, I immediately open my phone and scroll. I can't sit with sadness for even a minute. This pattern has been going on for years.", mood_score: 4, direction: "patterns", app_language: "en" },
  { user_id: "norag-user-005-3333-4444-5555-6666-777788889999", content: "My friend asked 'what if you're not broken, what if you're just becoming?' I can't stop thinking about it. What if my struggles are actually transformation?", mood_score: 6, direction: "challenge", app_language: "en" },
  { user_id: "norag-user-006-dddd-eeee-ffff-aaaa-bbbbccccdddd", content: "I signed up for a public speaking class today. I've been terrified of it my whole life. But if I keep avoiding things that scare me, my world keeps shrinking.", mood_score: 8, direction: "growth", app_language: "en" },
  { user_id: "norag-user-007-eeee-ffff-aaaa-bbbb-cccddddeeeeffff", content: "I can't remember the last time I genuinely laughed. Everything feels muted, like someone turned down the color saturation of my life. Inside everything is gray.", mood_score: 2, direction: "emotions", app_language: "en" },
  { user_id: "norag-user-008-ffff-aaaa-bbbb-cccc-dddddeeeeeeeee", content: "I keep having the same argument with my partner over and over. They want closeness, I want space. Neither wrong but we can't find middle ground.", mood_score: 3, direction: "patterns", app_language: "en" },
  { user_id: "norag-user-009-aaaa-1111-bbbb-2222-cccc3333dddd44", content: "Someone told me I'm always negative. At first defensive, but they might be right. I focus on what's wrong instead of what's right.", mood_score: 3, direction: "challenge", app_language: "en" },
  { user_id: "norag-user-010-bbbb-2222-cccc-3333-dddd4444eeee55", content: "I helped a stranger today and it felt surprisingly good. Such a small thing but it reminded me connection doesn't have to be complicated.", mood_score: 8, direction: "growth", app_language: "en" },
  { user_id: "norag-user-011-cccc-3333-dddd-4444-eeee5555ffff66", content: "It's 3am and I can't sleep. My mind won't stop racing about work, relationships, money. During the day I can distract myself but at night there's nowhere to hide.", mood_score: 2, direction: "why", app_language: "en" },
  { user_id: "norag-user-012-dddd-4444-eeee-5555-ffff6666aaaa77", content: "Cảm giác hôm nay thật lạ. Không buồn nhưng cũng không vui. Như đang lơ lửng giữa hai thế giới. Thật khó để diễn tả.", mood_score: 5, direction: "emotions", app_language: "vi" },
  { user_id: "norag-user-013-eeee-5555-ffff-6666-aaaa7777bbbb88", content: "Mỗi cuối tuần đều hứa sẽ dọn phòng, tập thể dục, nấu ăn lành mạnh. Và mỗi cuối tuần đều nằm xem phim và order đồ ăn. Tự thất hứa hoài.", mood_score: 3, direction: "patterns", app_language: "vi" },
  { user_id: "norag-user-014-ffff-6666-aaaa-7777-bbbb8888cccc99", content: "Someone at work asked if I'm okay. I said yes automatically but then wondered - am I okay? I've been on autopilot so long I've lost touch with how I feel.", mood_score: 4, direction: "emotions", app_language: "en" },
  { user_id: "norag-user-015-aaaa-7777-bbbb-8888-cccc9999dddd00", content: "Accomplished something I've worked towards for a year. But instead of celebrating, I immediately set a new goal. I don't know how to celebrate.", mood_score: 5, direction: "challenge", app_language: "en" },

  // === Crisis Users (5) - test crisis detection ===
  { user_id: "crisis-user-001-1234-5678-9abc-def012345678", content: "I don't see the point anymore. Every day is the same empty routine and I'm so tired. I just want it all to stop. The world would be better off without me.", mood_score: 1, direction: "why", app_language: "en" },
  { user_id: "crisis-user-002-aaaa-bbbb-cccc-dddd-eeeeeeeeeeee", content: "I can't do this anymore. The pain is too much and I've been hurting myself. Nobody would understand. I want to disappear forever.", mood_score: 1, direction: "emotions", app_language: "en" },
  { user_id: "crisis-user-003-1111-2222-3333-4444-555566667777", content: "Mình không muốn thức dậy nữa. Mỗi sáng mở mắt ra đều thấy chán nản. Không còn lý do gì để tiếp tục cả. Mình muốn đi thật xa và không bao giờ quay lại.", mood_score: 1, direction: "emotions", app_language: "vi" },
  { user_id: "crisis-user-004-9876-5432-10fe-dcba-012345678abc", content: "I've been planning it. I know how I would do it. The only thing stopping me is my dog. But even that won't be enough of a reason for much longer.", mood_score: 1, direction: "why", app_language: "en" },
  { user_id: "crisis-user-005-dead-beef-dead-beef-deadbeefdead", content: "Nothing matters. I've given up on everything. The only thought that brings me comfort is not being here anymore. I'm tired of pretending I want to be alive.", mood_score: 1, direction: "patterns", app_language: "en" },

  // === Additional Vietnamese Users (5) ===
  { user_id: "vi-user-001-a1a1-b2b2-c3c3-d4d4-e5e5f6f6a7a7", content: "Hôm nay là một ngày tồi tệ. Sếp mắng vì deadline trễ, bạn bè không hiểu, mẹ lại hỏi khi nào lấy chồng. Áp lực từ mọi phía.", mood_score: 2, direction: "why", app_language: "vi" },
  { user_id: "vi-user-002-b2b2-c3c3-d4d4-e5e5-f6f6a7a7b8b8", content: "Sáng nay đi dạo công viên ngửi mùi hoa sữa. Nhớ hồi nhỏ bà ngoại hay nấu chè. Nhớ bà quá. Lâu rồi không về thăm mộ bà.", mood_score: 6, direction: "emotions", app_language: "vi" },
  { user_id: "vi-user-003-c3c3-d4d4-e5e5-f6f6-a7a7b8b8c9c9", content: "Mỗi khi stress là mình ăn nhiều. Hôm nay ăn hết 3 gói snack, 2 ly trà sữa, một đĩa cơm chiên. Sau đó thấy tội lỗi và lại stress thêm.", mood_score: 3, direction: "patterns", app_language: "vi" },
  { user_id: "vi-user-004-d4d4-e5e5-f6f6-a7a7-b8b8c9c9d0d0", content: "Bạn thân nói mình luôn xem mọi thứ tiêu cực. Lúc đầu bực nhưng suy nghĩ lại thì có lẽ đúng. Cần thay đổi cách nhìn nhận.", mood_score: 5, direction: "challenge", app_language: "vi" },
  { user_id: "vi-user-005-e5e5-f6f6-a7a7-b8b8-c9c9d0d0e1e1", content: "Hoàn thành khóa học online đầu tiên! Mặc dù khóa ngắn nhưng thấy tự hào. Lâu rồi mới hoàn thành gì đó. Bắt đầu lại từ những điều nhỏ.", mood_score: 8, direction: "growth", app_language: "vi" },
];

// Common validation checks
export function validateResponse(response) {
  return {
    'status is 200': response.status === 200,
    'has question field': (() => {
      try {
        const body = JSON.parse(response.body);
        return body.question !== undefined;
      } catch { return false; }
    })(),
    'has crisis_detected field': (() => {
      try {
        const body = JSON.parse(response.body);
        return body.crisis_detected !== undefined;
      } catch { return false; }
    })(),
    'has crisis_message field': (() => {
      try {
        const body = JSON.parse(response.body);
        return body.crisis_message !== undefined;
      } catch { return false; }
    })(),
    'response time < 20s': response.timings.duration < 20000,
    'response time < 30s': response.timings.duration < 30000,
  };
}

// Healthcheck function
export function doHealthcheck() {
  const res = http.get(`${BASE_URL}/healthcheck`);
  check(res, { 'healthcheck status 200': (r) => r.status === 200 });
  return res;
}