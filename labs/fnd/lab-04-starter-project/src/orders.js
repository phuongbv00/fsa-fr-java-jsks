// A few OrderDesk orders to work against. No database, no framework.

const ORDERS = [
  {
    id: 5001,
    status: 'placed',
    deliveredAt: null,
    lines: [
      { sku: 'KB-01', quantity: 2, unitPrice: 150000, finalClearance: false },
      { sku: 'MS-04', quantity: 1, unitPrice: 99000, finalClearance: false },
    ],
    shipments: [],
  },
  {
    id: 5002,
    status: 'picking',
    deliveredAt: null,
    lines: [{ sku: 'KB-01', quantity: 1, unitPrice: 150000, finalClearance: false }],
    // Two parcels: the first has left the warehouse, the second has not.
    shipments: [
      { id: 9001, dispatchedAt: '2026-09-01T08:00:00Z' },
      { id: 9002, dispatchedAt: null },
    ],
  },
  {
    id: 5003,
    status: 'delivered',
    deliveredAt: '2026-08-20T10:00:00Z',
    lines: [{ sku: 'HP-07', quantity: 1, unitPrice: 450000, finalClearance: true }],
    shipments: [{ id: 9003, dispatchedAt: '2026-08-18T09:00:00Z' }],
  },
];

function findOrder(orderId) {
  return ORDERS.find((o) => o.id === orderId) ?? null;
}

module.exports = { ORDERS, findOrder };
