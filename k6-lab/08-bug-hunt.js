import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = 'https://quickpizza.grafana.com';
const PARAMS = { headers: {
  'Content-Type': 'application/json',
  Authorization: 'token abcdef0123456789',
} };

// Match the catalog's capitalization; verify with explore.js.
// ORIGINAL=1 reproduces the lowercase request from the assignment.
export default function () {
  const original = __ENV.ORIGINAL === '1';
  const body = JSON.stringify({
    excludedIngredients: [original ? 'pepperoni' : 'Pepperoni'],
    excludedTools: [original ? 'knife' : 'Knife'],
  });
  const res = http.post(`${BASE_URL}/api/pizza`, body, PARAMS);
  check(res, {
    'status is 200': (r) => r.status === 200,
    'no pepperoni': (r) => !r.json('pizza.ingredients').some((i) => i.name === 'Pepperoni'),
    'no knife needed': (r) => r.json('pizza.tool') !== 'Knife',
  });
  sleep(1);
}
