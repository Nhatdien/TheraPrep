// k6 Smoke Test - 1 VU, 1 iteration
// Purpose: Verify endpoint works, basic sanity check

import http from 'k6/http';
import { check, sleep } from 'k6';
import { BASE_URL, TEST_USERS, validateResponse } from './config.js';

export const options = {
  stages: [
    { duration: '5s', target: 1 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<30000'],
    http_req_failed: ['rate<0.1'],
    checks: ['rate>0.9'],
  },
  tags: { test_name: 'smoke' },
};

export default function () {
  // Healthcheck first
  const hc = http.get(`${BASE_URL}/healthcheck`);
  check(hc, { 'healthcheck 200': (r) => r.status === 200 });

  // Use first test user
  const user = TEST_USERS[0];
  const payload = JSON.stringify({
    user_id: user.user_id,
    content: user.content,
    mood_score: user.mood_score,
    direction: user.direction,
    app_language: user.app_language,
  });

  const params = {
    headers: { 'Content-Type': 'application/json' },
    tags: { endpoint: 'analyze-journal' },
    timeout: '30s',
  };

  const res = http.post(`${BASE_URL}/api/analyze-journal`, payload, params);
  check(res, validateResponse(res));

  console.log(`Smoke test - Status: ${res.status}, Time: ${res.timings.duration}ms`);

  sleep(1);
}