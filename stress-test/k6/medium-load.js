// k6 Medium Load Test - 25 VUs, 60s
// Purpose: Test moderate concurrent load

import http from 'k6/http';
import { check, sleep } from 'k6';
import { BASE_URL, TEST_USERS, validateResponse } from './config.js';

export const options = {
  stages: [
    { duration: '15s', target: 25 },   // Ramp up to 25 VUs
    { duration: '30s', target: 25 },   // Hold 25 VUs
    { duration: '10s', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<45000'],  // 95% under 45s (higher under load)
    http_req_failed: ['rate<0.15'],      // <15% errors
    checks: ['rate>0.7'],                // 70% checks pass
  },
  tags: { test_name: 'medium-load' },
};

export default function () {
  // Use first 25 users
  const userIndex = (__VU - 1) % 25;
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
    timeout: '60s',
  };

  const res = http.post(`${BASE_URL}/api/analyze-journal`, payload, params);
  check(res, validateResponse(res));

  sleep(0.2); // 200ms between requests per VU
}