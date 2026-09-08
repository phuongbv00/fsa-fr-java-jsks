const test = require('node:test');
const assert = require('node:assert/strict');

const { canCancel } = require('../src/cancellation');
const { findOrder } = require('../src/orders');

test('an order that has not shipped can be cancelled', () => {
  const result = canCancel(findOrder(5001));
  assert.equal(result.allowed, true);
});

test('a delivered order cannot be cancelled', () => {
  const result = canCancel(findOrder(5003));
  assert.equal(result.allowed, false);
  assert.match(result.reason, /cancelled/);
});

test('a refusal always carries a reason', () => {
  for (const id of [5002, 5003]) {
    const result = canCancel(findOrder(id));
    if (!result.allowed) {
      assert.notEqual(result.reason, '');
    }
  }
});
