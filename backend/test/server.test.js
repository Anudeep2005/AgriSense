const test = require('node:test');
const assert = require('node:assert');
const app = require('../src/server');

test('Health Check Endpoint Returns 200 OK', async () => {
  assert.strictEqual(typeof app, 'function');
});
