// k6 Spike Test - 50 VUs burst
// Purpose: Test sudden traffic spike, see how system recovers

import http from 'k6/http';
import { check, sleep } from 'k6';
import { BASE_URL, TEST_USERS, validateResponse } from './config.js';

export const options = {
  stages: [
    { duration: '2s', target: 50 },    // Instant spike to 50
    { duration: '30s', target: 50 },   // Hold at 50
    { duration: '5s', target: 0 },     // Quick ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<90000'],  // Very generous for spike
    http_req_failed: ['rate<0.35'],      // Up to 35% errors during spike
    checks: ['rate>0.5'],                // 50% checks pass minimum
  },
  tags: { test_name: 'spike' },
};

export default function () {
  const userIndex = (__VU - 1) % TEST_USERS.length;
  const user = TEST_USERS[userIndex];

  const payload = JSON.stringify({
    user_id: user.user_id,
    content: user.content,
    mood_score: user.mood_score,
    direction: user.direction,
    app_language: user.app_language,
  });

  const params = {
    headers: { 'Content-Type': 'application/json' },
    tags: { endpoint: 'analyze-journal', direction: user.direction },
    timeout: '120s',
  };

  const res = http.post(`${BASE_URL}/api/analyze-journal`, payload, params);
  check(res, validateResponse(res));

  // No sleep - maximum burst
}