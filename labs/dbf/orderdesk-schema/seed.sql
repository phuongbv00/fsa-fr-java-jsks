-- A small, fixed data set. Ids are set explicitly (OVERRIDING SYSTEM VALUE) so that the
-- notes, the tests and the trainer all mean the same row when they say "order 5001".
-- Money is in VND, so unit prices are whole numbers.

INSERT INTO staff OVERRIDING SYSTEM VALUE (staff_id, email, full_name, role) VALUES
    (1, 'linh@orderdesk.example', 'Linh Nguyen', 'supervisor'),
    (2, 'tuan@orderdesk.example', 'Tuan Pham',   'refunds_clerk'),
    (3, 'hoa@orderdesk.example',  'Hoa Le',      'picker');

INSERT INTO customer OVERRIDING SYSTEM VALUE (customer_id, email, full_name) VALUES
    (42, 'mai@example.com',  'Mai Tran'),
    (99, 'binh@example.com', 'Binh Vo');

INSERT INTO product OVERRIDING SYSTEM VALUE (product_id, sku, display_name, unit_price, is_active) VALUES
    (1, 'KB-01', 'Keyboard',  150000, true),
    (2, 'MS-04', 'Mouse',      99000, true),
    (3, 'HP-07', 'Headphones', 450000, true),
    (4, 'CB-02', 'USB-C cable', 60000, false);   -- discontinued: kept for order history

-- 5001: placed, nothing packed. 5002: picking, one of two parcels dispatched.
-- 5003: delivered. 5004: cancelled.
INSERT INTO orders OVERRIDING SYSTEM VALUE (order_id, customer_id, placed_at, status) VALUES
    (5001, 42, '2026-09-01T09:15:00Z', 'placed'),
    (5002, 42, '2026-08-28T14:02:00Z', 'picking'),
    (5003, 99, '2026-08-15T11:40:00Z', 'delivered'),
    (5004, 42, '2026-08-10T08:00:00Z', 'cancelled');

INSERT INTO order_line OVERRIDING SYSTEM VALUE (order_line_id, order_id, product_id, quantity, unit_price) VALUES
    (1, 5001, 1, 2, 150000),
    (2, 5001, 2, 1,  99000),
    (3, 5002, 1, 1, 150000),
    (4, 5002, 3, 1, 450000),
    (5, 5003, 3, 1, 450000),
    (6, 5004, 4, 3,  60000);

INSERT INTO shipment OVERRIDING SYSTEM VALUE (shipment_id, order_id, tracking_number, dispatched_at, delivered_at) VALUES
    (9001, 5002, 'TRK-9001', '2026-09-01T08:00:00Z', NULL),   -- left the warehouse
    (9002, 5002, 'TRK-9002', NULL,                   NULL),   -- packed, not yet dispatched
    (9003, 5003, 'TRK-9003', '2026-08-18T09:00:00Z', '2026-08-20T10:00:00Z');

INSERT INTO shipment_line OVERRIDING SYSTEM VALUE (shipment_line_id, shipment_id, order_line_id, quantity) VALUES
    (1, 9001, 3, 1),
    (2, 9002, 4, 1),
    (3, 9003, 5, 1);

-- One return, approved by the refunds clerk with the reason the audit asked for.
INSERT INTO return_request OVERRIDING SYSTEM VALUE
    (return_request_id, order_id, raised_at, approved_by, approved_at, reason) VALUES
    (1, 5003, '2026-08-25T10:00:00Z', 2, '2026-08-26T09:30:00Z', 'faulty on arrival');

INSERT INTO return_line OVERRIDING SYSTEM VALUE (return_line_id, return_request_id, order_line_id, quantity) VALUES
    (1, 1, 5, 1);

-- Move every identity sequence past the explicit ids, so the next generated id does not collide.
SELECT setval(pg_get_serial_sequence('staff', 'staff_id'),                     (SELECT max(staff_id) FROM staff));
SELECT setval(pg_get_serial_sequence('customer', 'customer_id'),               (SELECT max(customer_id) FROM customer));
SELECT setval(pg_get_serial_sequence('product', 'product_id'),                 (SELECT max(product_id) FROM product));
SELECT setval(pg_get_serial_sequence('orders', 'order_id'),                    (SELECT max(order_id) FROM orders));
SELECT setval(pg_get_serial_sequence('order_line', 'order_line_id'),           (SELECT max(order_line_id) FROM order_line));
SELECT setval(pg_get_serial_sequence('shipment', 'shipment_id'),               (SELECT max(shipment_id) FROM shipment));
SELECT setval(pg_get_serial_sequence('shipment_line', 'shipment_line_id'),     (SELECT max(shipment_line_id) FROM shipment_line));
SELECT setval(pg_get_serial_sequence('return_request', 'return_request_id'),   (SELECT max(return_request_id) FROM return_request));
SELECT setval(pg_get_serial_sequence('return_line', 'return_line_id'),         (SELECT max(return_line_id) FROM return_line));
