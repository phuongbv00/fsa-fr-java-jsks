const assert = require('assert');
const { openReturn } = require('../src/returns');

// Test 1: Refuse return when all items are final clearance
assert.throws(
  () => {
    openReturn({ id: 'ORD-1001' }, [
      { sku: 'ITEM-1', finalClearance: true },
      { sku: 'ITEM-2', finalClearance: true },
    ]);
  },
  /final clearance/,
  'Should refuse return when all items are final clearance'
);

// Test 2: Filter out final clearance items from mixed return
const mixedResult = openReturn({ id: 'ORD-1002' }, [
  { sku: 'ITEM-1', finalClearance: true },
  { sku: 'ITEM-3', finalClearance: false },
]);
assert.strictEqual(mixedResult.lines.length, 1);
assert.strictEqual(mixedResult.lines[0].sku, 'ITEM-3');

// Test 3: Allow return with normal items
const normalResult = openReturn({ id: 'ORD-1003' }, [
  { sku: 'ITEM-4', finalClearance: false },
]);
assert.strictEqual(normalResult.lines.length, 1);

console.log('All tests for final clearance policy passed!');
