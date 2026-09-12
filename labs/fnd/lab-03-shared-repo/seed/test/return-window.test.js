const assert = require('assert');
const { openReturn } = require('../src/returns');

const DAY_MS = 24 * 60 * 60 * 1000;
const now = Date.now();

// Test 1: Refuse return opened more than 30 days after delivery (e.g. 31 days)
assert.throws(
  () => {
    const deliveredAt = new Date(now - 31 * DAY_MS).toISOString();
    openReturn({ id: 'ORD-2001', deliveredAt }, [{ sku: 'ITEM-1', quantity: 1 }]);
  },
  /window/,
  'Should refuse return opened past 30 days'
);

// Test 2: Allow return opened exactly 30 days after delivery
const day30Delivery = new Date(now - 30 * DAY_MS).toISOString();
const resultDay30 = openReturn({ id: 'ORD-2002', deliveredAt: day30Delivery }, [
  { sku: 'ITEM-2', quantity: 1 },
]);
assert.strictEqual(resultDay30.orderId, 'ORD-2002');

// Test 3: Allow return opened within window (e.g. 10 days)
const day10Delivery = new Date(now - 10 * DAY_MS).toISOString();
const resultDay10 = openReturn({ id: 'ORD-2003', deliveredAt: day10Delivery }, [
  { sku: 'ITEM-3', quantity: 1 },
]);
assert.strictEqual(resultDay10.orderId, 'ORD-2003');

// Test 4: Allow return when order has no deliveredAt (not delivered yet)
const resultUndelivered = openReturn({ id: 'ORD-2004', deliveredAt: null }, [
  { sku: 'ITEM-4', quantity: 1 },
]);
assert.strictEqual(resultUndelivered.orderId, 'ORD-2004');

console.log('All tests for 30-day return window policy passed!');
