// k6 Light Load Test - 10 VUs, 30s
// Purpose: Test with light concurrent load

import http from 'k6/http';
import { check, sleep } from 'k6';
import { SharedArray } from 'k6/data';
import { BASE_URL, TEST_USERS, validateResponse } from './config.js';

export const options = {
  stages: [
    { duration: '10s', target: 10 },   // Ramp up to 10 VUs
    { duration: '20s', target: 10 },   // Hold 10 VUs
    { duration: '5s', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<30000'],  // 95% under 30s
    http_req_failed: ['rate<0.1'],       // <10% errors
    checks: ['rate>0.8'],                // 80% checks pass
  },
  tags: { test_name: 'light-load' },
};

export default function () {
  // Each VU picks a user based on its index (use first 10 users)
  const userIndex = (__VU - 1) % 10;
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
    timeout: '30s',
  };

  const res = http.post(`${BASE_URL}/api/analyze-journal`, payload, params);
  check(res, validateResponse(res));

  sleep(0.5); // 500ms between requests per VU
}