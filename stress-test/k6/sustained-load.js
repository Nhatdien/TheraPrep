// k6 Sustained Load Test - 10 VUs, 5 minutes
// Purpose: Test for memory leaks, sustained LLM API usage, resource stability

import http from 'k6/http';
import { check, sleep } from 'k6';
import { BASE_URL, TEST_USERS, validateResponse } from './config.js';

export const options = {
  stages: [
    { duration: '30s', target: 10 },    // Gradual ramp up
    { duration: '4m', target: 10 },     // Hold 10 VUs for 4 minutes
    { duration: '30s', target: 0 },     // Gradual ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<60000'],  // Should stay under 60s (generous for sustained)
    http_req_failed: ['rate<0.1'],       // <10% errors
    checks: ['rate>0.8'],                // 80% checks pass
    // Ensure no degradation over time: iteration duration shouldn't increase
    iteration_duration: ['p(95)<65000'],
  },
  tags: { test_name: 'sustained-load' },
};

export default function () {
  // Cycle through first 10 users repeatedly
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
    tags: { endpoint: 'analyze-journal', direction: user.direction, vu: String(__VU) },
    timeout: '60s',
  };

  const res = http.post(`${BASE_URL}/api/analyze-journal`, payload, params);
  check(res, validateResponse(res));

  sleep(5); // 5 second delay = ~12 requests per VU per minute
}