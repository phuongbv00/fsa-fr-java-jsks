const test = require('node:test');
const assert = require('node:assert/strict');

const { openReturn, approve } = require('../src/returns');
const { findOrder } = require('../src/orders');

test('a return covers the lines it was given', () => {
  const order = findOrder(5001);
  const request = openReturn(order, order.lines.slice(0, 1));
  assert.equal(request.orderId, 5001);
  assert.equal(request.lines.length, 1);
});

test('a return must cover at least one line', () => {
  assert.throws(() => openReturn(findOrder(5001), []), /at least one line/);
});

test('an approval records the clerk and the reason', () => {
  const order = findOrder(5003);
  const request = openReturn(order, order.lines);
  const approved = approve(request, 77, 'faulty on arrival');
  assert.equal(approved.approvedBy, 77);
  assert.equal(approved.reason, 'faulty on arrival');
});

test('an approval without a reason is refused', () => {
  const order = findOrder(5003);
  const request = openReturn(order, order.lines);
  assert.throws(() => approve(request, 77, ''), /reason/);
});
