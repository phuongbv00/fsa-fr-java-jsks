// Returns handling for OrderDesk.

/**
 * Open a return request against an order.
 *
 * @param {object} order
 * @param {Array}  lines  the order lines being sent back
 * @returns {object} the new return request
 */
function openReturn(order, lines) {
  if (lines.length === 0) {
    throw new Error('a return must cover at least one line');
  }

  return {
    orderId: order.id,
    lines,
    raisedAt: new Date().toISOString(),
    approvedBy: null,
    approvedAt: null,
    reason: null,
  };
}

/**
 * Approve a refund against a return request.
 * A refunds clerk must approve, and must give a reason.
 */
function approve(returnRequest, clerkId, reason) {
  if (!reason) {
    throw new Error('a refund approval must carry a reason');
  }

  return {
    ...returnRequest,
    approvedBy: clerkId,
    approvedAt: new Date().toISOString(),
    reason,
  };
}

module.exports = { openReturn, approve };
