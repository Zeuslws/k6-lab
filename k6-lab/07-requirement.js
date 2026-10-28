import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = 'https://quickpizza.grafana.com';
const PARAMS = { headers: {
  'Content-Type': 'application/json',
  Authorization: 'token abcdef0123456789',
} };

// Set P95=1 for the deliberately stricter second run.
const P95 = __ENV.P95 || 1000;
export const options = {
  vus: 3, duration: '30s',
  summaryTrendStats: ['avg', 'min', 'med', 'max', 'p(90)', 'p(95)', 'p(99)'],
  thresholds: {
    http_req_duration: [`p(95)<${P95}`, 'p(99)<1500'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const res = http.post(`${BASE_URL}/api/pizza`, JSON.stringify({ mustBeVegetarian: true }), PARAMS);
  check(res, {
    'status is 200': (r) => r.status === 200,
    'pizza has a name': (r) => r.json('pizza.name') !== undefined,
  });
  sleep(1);
}
