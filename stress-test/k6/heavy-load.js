// k6 Heavy Load Test - 50 VUs, 120s
// Purpose: Test heavy concurrent load, find bottlenecks

import http from 'k6/http';
import { check, sleep } from 'k6';
import { BASE_URL, TEST_USERS, validateResponse } from './config.js';

export const options = {
  stages: [
    { duration: '20s', target: 20 },   // Gradual ramp up
    { duration: '10s', target: 50 },   // Spike to 50
    { duration: '60s', target: 50 },   // Hold 50 VUs
    { duration: '20s', target: 20 },   // Partial ramp down
    { duration: '10s', target: 0 },    // Full ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<60000'],  // 95% under 60s (generous for heavy load)
    http_req_failed: ['rate<0.25'],      // <25% errors acceptable under heavy load
    checks: ['rate>0.6'],                // 60% checks pass
  },
  tags: { test_name: 'heavy-load' },
};

export default function () {
  // Cycle through all 50 users
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
    timeout: '90s',
  };

  const res = http.post(`${BASE_URL}/api/analyze-journal`, payload, params);
  check(res, validateResponse(res));

  sleep(0.1); // 100ms between requests per VU
}