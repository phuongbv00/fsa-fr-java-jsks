# DDL, Constraints & Data Integrity

> Objectives: DBF-K1 · Session 2 · PostgreSQL 16 · See [Database Foundations — Study Guide](index.md).

## 1. Objectives

After this unit, learners can:

- Choose an appropriate data type for a column and say what the alternatives would permit.
- Write `CREATE TABLE` statements implementing a model, with keys and constraints.
- Enforce a domain rule with `NOT NULL`, `UNIQUE`, `CHECK` or a foreign key, and justify the choice.
- Choose a referential action (`RESTRICT`, `CASCADE`, `SET NULL`) and defend it against the others.
- Write a schema script that runs repeatably from a clean database.

## 2. DDL Is the Model, Written Down

The previous unit produced a diagram. A diagram is a proposal. DDL is the proposal enforced:
after `CREATE TABLE` runs, the constraints are true of every row that will ever exist, whether
inserted by your application, a colleague's script, or somebody at a `psql` prompt at 2am.

That last part is the argument for putting rules in the database. Application-level validation
protects one path in. A constraint protects the data.

```sql
-- The model from unit 1, made real.
CREATE TABLE customer (
    customer_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email       text        NOT NULL UNIQUE,
    full_name   text        NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);
```

Four decisions are already encoded there, and each forbids something: no customer without an
email, no two customers sharing one, no anonymous customer, no customer whose creation time
is unknown.

## 3. Data Types

A type is the first constraint. Choosing loosely means enforcing later, or not at all.

| Need | Use | Not | Because |
|---|---|---|---|
| Identifier | `bigint GENERATED ALWAYS AS IDENTITY` | `serial` | `serial` is legacy; identity is standard SQL |
| Short text with no length rule | `text` | `varchar(255)` | 255 is a number somebody made up; it is not a domain rule |
| Text with a real length rule | `varchar(n)` | `text` | When the rule exists, enforce it |
| Money | `numeric(12,2)` | `float` / `real` | Binary floats cannot represent `0.10`; totals drift |
| Quantity | `integer` | `numeric` | Whole things are whole |
| A point in time | `timestamptz` | `timestamp` | `timestamp` has no timezone and silently means "somewhere" |
| A calendar day | `date` | `timestamptz` | A birthday is not an instant |
| True/false | `boolean` | `char(1)`, `integer` | `'Y'`, `'y'`, `1`, `-1` all become possible otherwise |
| A fixed set of values | `text` + `CHECK` | free `text` | See section 5 |

The money one is worth demonstrating, because it is the mistake with the largest blast radius:

```sql
-- Wrong — floating point money
SELECT 0.1::real + 0.2::real = 0.3::real;   -- f

-- Right — exact decimal
SELECT 0.1::numeric + 0.2::numeric = 0.3::numeric;   -- t
```

> **Real-world use.** An invoice total computed in `float` disagrees with the sum of its lines
> by a few cents, irregularly. It is not reproducible, so it gets attributed to "a rounding
> thing" and lives for years.

And the timestamp one, which is the mistake that survives longest undetected:

```sql
-- Wrong — no timezone. Ambiguous the moment a second machine writes to it.
dispatched_at timestamp

-- Right — an unambiguous instant, rendered in whatever zone you ask for
dispatched_at timestamptz
```

## 4. Keys in DDL

```sql
CREATE TABLE product (
    product_id   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku          text          NOT NULL UNIQUE,
    display_name text          NOT NULL,
    unit_price   numeric(12,2) NOT NULL CHECK (unit_price >= 0),
    is_active    boolean       NOT NULL DEFAULT true
);

CREATE TABLE orders (
    order_id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id bigint      NOT NULL REFERENCES customer (customer_id),
    placed_at   timestamptz NOT NULL DEFAULT now(),
    status      text        NOT NULL DEFAULT 'placed'
        CHECK (status IN ('placed', 'picking', 'dispatched', 'delivered', 'cancelled'))
);

CREATE TABLE order_line (
    order_line_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id      bigint        NOT NULL REFERENCES orders (order_id) ON DELETE CASCADE,
    product_id    bigint        NOT NULL REFERENCES product (product_id),
    quantity      integer       NOT NULL CHECK (quantity > 0),
    unit_price    numeric(12,2) NOT NULL CHECK (unit_price >= 0),
    -- One product appears at most once per order; change the quantity instead.
    UNIQUE (order_id, product_id)
);
```

That last `UNIQUE` is a domain rule discovered by asking a question the diagram did not: *can
the same product appear twice on one order?* If the answer is no, say so here. If nobody
asks, the answer becomes "yes, accidentally, sometimes".

> **Note.** A composite `UNIQUE` is not the same as a composite primary key. Here the identity
> is still the surrogate; `(order_id, product_id)` is a business rule layered on top.

## 5. Constraints, One by One

### `NOT NULL`

`NULL` means "unknown", and it propagates: `NULL = NULL` is not true, it is `NULL`. Every
nullable column is a question you are declining to answer, so make it deliberate.

```sql
-- dispatched_at is genuinely unknown until dispatch. Nullable is correct.
dispatched_at timestamptz,

-- A shipment with no order is not a shipment. Nullable would be wrong.
order_id bigint NOT NULL REFERENCES orders (order_id)
```

### `UNIQUE`

Says two rows may not agree here. Note that `NULL`s do not conflict — several rows may have
`NULL` in a `UNIQUE` column, because unknowns are not known to be equal.

### `CHECK`

Constrains the values of a single row. This is where most domain rules land.

```sql
CHECK (quantity > 0)
CHECK (unit_price >= 0)
CHECK (status IN ('placed', 'picking', 'dispatched', 'delivered', 'cancelled'))
CHECK (delivered_at IS NULL OR dispatched_at IS NOT NULL)   -- cannot arrive before it left
```

That last one is the interesting shape: a `CHECK` may reference several columns of the same
row, which lets you enforce rules *between* fields.

```sql
-- Wrong — the rule lives in a comment and in application code
-- (a return must have a reason if it was approved)
approved_by bigint REFERENCES staff (staff_id),
reason      text

-- Right — the rule is enforced
approved_by bigint REFERENCES staff (staff_id),
reason      text,
CHECK (approved_by IS NULL OR reason IS NOT NULL)
```

> **Note.** A `CHECK` cannot query another table. When a rule spans rows or tables, it needs a
> foreign key, a `UNIQUE`, or a trigger — and if you reach for a trigger, be sure the rule is
> really not expressible as one of the first two.

### `DEFAULT`

Supplies a value when the insert does not. `DEFAULT now()` on `created_at` is the common case
and removes an entire class of "the application forgot" bug.

### Naming constraints

Unnamed constraints get generated names, and generated names appear in the error message your
learner or your colleague has to interpret.

```sql
-- The error says: violates check constraint "order_line_quantity_check"
CHECK (quantity > 0)

-- The error says: violates check constraint "order_line_quantity_positive"
CONSTRAINT order_line_quantity_positive CHECK (quantity > 0)
```

## 6. Referential Actions

A foreign key stops you deleting a parent that has children. What it does *instead* is your
choice, and the choice is a domain decision, not a technical one.

| Action | On deleting the parent | Use when |
|---|---|---|
| `RESTRICT` / `NO ACTION` | Refuses | The child is independently meaningful — the default, and correct far more often than not |
| `CASCADE` | Deletes the children too | The child cannot exist alone and has no independent value |
| `SET NULL` | Nulls the child's reference | The link is optional and losing it is acceptable |

Applied to OrderDesk:

```sql
-- CASCADE: an order line is part of its order. Delete the order, the lines go.
order_id bigint NOT NULL REFERENCES orders (order_id) ON DELETE CASCADE,

-- RESTRICT (the default): deleting a product that has been ordered would erase
-- history. Deactivate it instead — which is why product.is_active exists.
product_id bigint NOT NULL REFERENCES product (product_id),

-- SET NULL: if a staff account is removed, the return stays; we just no longer
-- know who approved it.
approved_by bigint REFERENCES staff (staff_id) ON DELETE SET NULL,
```

> **Note.** `ON DELETE CASCADE` is easy to over-apply because it makes errors go away. It makes
> them go away by deleting data. Reach for it only when the child genuinely cannot exist
> without the parent.

## 7. Worked Example — A Repeatable Schema Script

Every assessment in this module runs your script against a database that has just been created.
That constraint shapes how the script is written: order matters, and re-running must be safe.

```sql
-- schema.sql — runs from nothing, in order, every time.

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
    staff_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email    text NOT NULL UNIQUE,
    full_name text NOT NULL,
    role     text NOT NULL CHECK (role IN ('picker', 'refunds_clerk', 'supervisor'))
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
    unit_price   numeric(12,2) NOT NULL CHECK (unit_price >= 0),
    is_active    boolean NOT NULL DEFAULT true
);

CREATE TABLE orders (
    order_id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES customer (customer_id),
    placed_at   timestamptz NOT NULL DEFAULT now(),
    status      text NOT NULL DEFAULT 'placed'
        CHECK (status IN ('placed', 'picking', 'dispatched', 'delivered', 'cancelled'))
);

CREATE TABLE order_line (
    order_line_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id      bigint NOT NULL REFERENCES orders (order_id) ON DELETE CASCADE,
    product_id    bigint NOT NULL REFERENCES product (product_id),
    quantity      integer NOT NULL CHECK (quantity > 0),
    unit_price    numeric(12,2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT order_line_one_row_per_product UNIQUE (order_id, product_id)
);

CREATE TABLE shipment (
    shipment_id     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id        bigint NOT NULL REFERENCES orders (order_id) ON DELETE CASCADE,
    tracking_number text NOT NULL UNIQUE,
    dispatched_at   timestamptz NOT NULL DEFAULT now(),
    delivered_at    timestamptz,
    CONSTRAINT shipment_delivery_after_dispatch
        CHECK (delivered_at IS NULL OR delivered_at >= dispatched_at)
);

CREATE TABLE shipment_line (
    shipment_line_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipment_id      bigint NOT NULL REFERENCES shipment (shipment_id) ON DELETE CASCADE,
    order_line_id    bigint NOT NULL REFERENCES order_line (order_line_id),
    quantity         integer NOT NULL CHECK (quantity > 0),
    CONSTRAINT shipment_line_one_row_per_order_line UNIQUE (shipment_id, order_line_id)
);

CREATE TABLE return_request (
    return_request_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id    bigint NOT NULL REFERENCES orders (order_id),
    raised_at   timestamptz NOT NULL DEFAULT now(),
    reason      text NOT NULL,
    approved_by bigint REFERENCES staff (staff_id) ON DELETE SET NULL,
    approved_at timestamptz,
    CONSTRAINT return_approval_is_complete
        CHECK ((approved_by IS NULL) = (approved_at IS NULL))
);

CREATE TABLE return_line (
    return_line_id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    return_request_id bigint NOT NULL REFERENCES return_request (return_request_id) ON DELETE CASCADE,
    order_line_id     bigint NOT NULL REFERENCES order_line (order_line_id),
    quantity          integer NOT NULL CHECK (quantity > 0)
);
```

Prove it is repeatable, and prove the constraints bite:

```bash
dropdb --if-exists orderdesk && createdb orderdesk
psql orderdesk -f schema.sql        # must succeed
psql orderdesk -f schema.sql        # must succeed again, unchanged
```

```sql
-- Evidence that the rules are enforced. Each of these must fail.
INSERT INTO order_line (order_id, product_id, quantity, unit_price)
VALUES (1, 1, 0, 10.00);
-- ERROR: new row violates check constraint "order_line_quantity_check"

INSERT INTO orders (customer_id, status) VALUES (1, 'shpped');
-- ERROR: new row violates check constraint "orders_status_check"

DELETE FROM product WHERE product_id = 1;
-- ERROR: update or delete on table "product" violates foreign key constraint
```

> **Tip.** Keep those failing statements in a file called `constraints_evidence.sql`. A claim
> that a constraint works is worth nothing without the error it produces; the assignment asks
> for exactly this.

## 8. Common Problems

### `ERROR: relation "customer" does not exist`

The script creates tables in the wrong order — a table referencing `customer` runs before
`customer` exists. Create parents first; drop children first.

### `ERROR: column "x" of relation "y" contains null values`

Adding `NOT NULL` to a column of a table that already has rows. Backfill first, then constrain:

```sql
UPDATE orders SET status = 'placed' WHERE status IS NULL;
ALTER TABLE orders ALTER COLUMN status SET NOT NULL;
```

### The script only runs on an empty database

Almost always missing `DROP TABLE IF EXISTS`, or dropping in the wrong order. The fix is the
rebuild loop in the handbook: if you develop against a clean database you find this on day one
rather than at acceptance.

### `ERROR: duplicate key value violates unique constraint`

Something is being inserted twice. If it is your seed script, it is not idempotent — either
drop first, or make the insert conditional.

### Everything is `text` and nullable

Usually the result of generating DDL from sample data. It compiles, it accepts anything, and
every rule then has to be enforced somewhere else, forever.

## 9. Practical Guidelines

- Write `NOT NULL` by default; make nullability a decision you can defend.
- Name every `CHECK` and `UNIQUE` constraint, so the error message names the rule.
- Use `numeric` for money and `timestamptz` for instants, without exception.
- Default to `RESTRICT` on foreign keys; use `CASCADE` only for parts of a whole.
- Make the schema script idempotent from day one, and run it from a clean database daily.
- Capture the failing statement whenever you add a constraint — that is your evidence.

## 10. Knowledge Check

1. Why is `numeric(12,2)` right for money and `real` wrong? Give a statement that shows it.
2. A `UNIQUE` column contains three rows with `NULL`. Is that a constraint violation? Why?
3. `order_line.order_id` cascades on delete but `order_line.product_id` restricts. Justify
   both, in domain terms.
4. Write a `CHECK` enforcing "a return is either fully unapproved, or has both an approver and
   an approval time".
5. Your schema script runs once and fails the second time. Name two likely causes.

## 11. Further Reading

- [PostgreSQL: Constraints](https://www.postgresql.org/docs/16/ddl-constraints.html)
- [PostgreSQL: Data Types](https://www.postgresql.org/docs/16/datatype.html)
- [PostgreSQL: ALTER TABLE](https://www.postgresql.org/docs/16/sql-altertable.html)

---

Next: [Lab 02 — Implement the model as runnable DDL](lab-02.md), then [SQL Querying, Plans & Transactions](querying-plans-and-transactions.md).
