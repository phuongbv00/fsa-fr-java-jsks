// Cancellation rules for OrderDesk.

const CANCELLABLE_STATUSES = ['placed', 'picking'];

/**
 * Decide whether an order may be cancelled.
 *
 * @param {object} order
 * @returns {{allowed: boolean, reason: string}}
 */
function canCancel(order) {
  if (!CANCELLABLE_STATUSES.includes(order.status)) {
    return {
      allowed: false,
      reason: 'This order can no longer be cancelled.',
    };
  }

  if (order.shipments.length > 0) {
    return {
      allowed: false,
      reason: 'This order can no longer be cancelled.',
    };
  }

  return { allowed: true, reason: '' };
}

function recordCancellation(order, clerkId) {
  return {
    orderId: order.id,
    clerkId,
    at: new Date().toISOString(),
    action: 'cancelled',
  };
}

module.exports = { canCancel, recordCancellation, CANCELLABLE_STATUSES };
