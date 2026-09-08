-- OrderDesk order schema. The worked example from Database Foundations unit 2, and the
-- database the Java modules read and write. Runs from nothing, in order, every time.

-- Dropped in reverse dependency order: children before parents.
DROP TABLE IF EXISTS return_line;
DROP TABLE IF EXISTS return_request;
DROP TABLE IF EXISTS shipment_line;
DROP TABLE IF EXISTS shipment;
DROP TABLE IF EXISTS order_line;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS staff;

CREATE TABLE staff (
    staff_id  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email     text NOT NULL UNIQUE,
    full_name text NOT NULL,
    role      text NOT NULL
        CONSTRAINT staff_role_known CHECK (role IN ('picker', 'refunds_clerk', 'supervisor'))
);

CREATE TABLE customer (
    customer_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email       text NOT NULL UNIQUE,
    full_name   text NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE product (
    product_id   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku          text NOT NULL UNIQUE,
    display_name text NOT NULL,
    unit_price   numeric(12,2) NOT NULL
        CONSTRAINT product_unit_price_not_negative CHECK (unit_price >= 0),
    is_active    boolean NOT NULL DEFAULT true
);

CREATE TABLE orders (
    order_id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES customer (customer_id) ON DELETE RESTRICT,
    placed_at   timestamptz NOT NULL DEFAULT now(),
    -- Lower case on purpose: the Java enum maps to these values through dbValue().
    status      text NOT NULL DEFAULT 'placed'
        CONSTRAINT orders_status_known
        CHECK (status IN ('placed', 'picking', 'dispatched', 'delivered', 'cancelled'))
);

CREATE TABLE order_line (
    order_line_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id      bigint NOT NULL REFERENCES orders (order_id) ON DELETE CASCADE,
    product_id    bigint NOT NULL REFERENCES product (product_id) ON DELETE RESTRICT,
    quantity      integer NOT NULL
        CONSTRAINT order_line_quantity_positive CHECK (quantity > 0),
    -- What it cost then, not what the product costs now.
    unit_price    numeric(12,2) NOT NULL
        CONSTRAINT order_line_unit_price_not_negative CHECK (unit_price >= 0),
    CONSTRAINT order_line_one_row_per_product UNIQUE (order_id, product_id)
);

CREATE TABLE shipment (
    shipment_id     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id        bigint NOT NULL REFERENCES orders (order_id) ON DELETE CASCADE,
    tracking_number text NOT NULL UNIQUE,
    -- A parcel exists once it is packed; it is dispatched later, so this is nullable.
    dispatched_at   timestamptz,
    delivered_at    timestamptz,
    CONSTRAINT shipment_delivery_after_dispatch
        CHECK (delivered_at IS NULL
               OR (dispatched_at IS NOT NULL AND delivered_at >= dispatched_at))
);

CREATE TABLE shipment_line (
    shipment_line_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipment_id      bigint NOT NULL REFERENCES shipment (shipment_id) ON DELETE CASCADE,
    order_line_id    bigint NOT NULL REFERENCES order_line (order_line_id) ON DELETE RESTRICT,
    quantity         integer NOT NULL
        CONSTRAINT shipment_line_quantity_positive CHECK (quantity > 0),
    CONSTRAINT shipment_line_one_row_per_order_line UNIQUE (shipment_id, order_line_id)
);

CREATE TABLE return_request (
    return_request_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id    bigint NOT NULL REFERENCES orders (order_id) ON DELETE RESTRICT,
    raised_at   timestamptz NOT NULL DEFAULT now(),
    approved_by bigint REFERENCES staff (staff_id) ON DELETE SET NULL,
    approved_at timestamptz,
    reason      text,
    -- Unapproved: all three null. Approved: clerk, time and reason all present.
    CONSTRAINT return_approval_is_complete
        CHECK ((approved_by IS NULL) = (approved_at IS NULL)
               AND (approved_by IS NULL OR reason IS NOT NULL))
);

CREATE TABLE return_line (
    return_line_id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    return_request_id bigint NOT NULL REFERENCES return_request (return_request_id) ON DELETE CASCADE,
    order_line_id     bigint NOT NULL REFERENCES order_line (order_line_id) ON DELETE RESTRICT,
    quantity          integer NOT NULL
        CONSTRAINT return_line_quantity_positive CHECK (quantity > 0)
);
