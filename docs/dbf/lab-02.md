# Lab 02 — Implement the model as runnable DDL

**Duration:** 150 min

## Objectives

By the end of this lab you will be able to:

- Turn an ERD into `CREATE TABLE` statements with appropriate types.
- Enforce domain rules with `NOT NULL`, `UNIQUE`, `CHECK` and foreign keys.
- Choose a referential action per foreign key and justify it.
- Write a schema script that runs repeatably against a clean database.
- Produce evidence that each constraint rejects the data it is meant to reject.

## Before you start

- You have read [DDL, Constraints & Data Integrity](ddl-and-constraints.md).
- Lab 01 is complete — this lab implements *your* ERD from it.
- `psql --version` reports 18.x, and `createdb` works.

## Steps

1. **Make the rebuild loop first.** Before writing any DDL, create `rebuild.sh`:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   dropdb --if-exists orderdesk_supply
   createdb orderdesk_supply
   psql -v ON_ERROR_STOP=1 orderdesk_supply -f schema.sql
   psql -v ON_ERROR_STOP=1 orderdesk_supply -f seed.sql
   echo "rebuilt"
   ```

   `ON_ERROR_STOP=1` matters: without it `psql` reports failures and carries on, and your
   script "succeeds" with half a schema.

2. **Write `schema.sql` in dependency order.** Parents before children. Open the file with
   `DROP TABLE IF EXISTS` for every table, in reverse order, so the script is repeatable.

3. **Type every column deliberately.** Money is `numeric(12,2)`, instants are `timestamptz`,
   quantities are `integer`, flags are `boolean`. For each column where you considered a
   different type, leave a comment saying what you rejected.

4. **Add the constraints your ERD implies.** At minimum:

   - every foreign key from the diagram, with an explicit referential action
   - `NOT NULL` on everything that is not genuinely optional
   - `UNIQUE` on every natural key you kept
   - a `CHECK` on every enumerated column, listing the values from the brief
   - a `CHECK` on every quantity and price, rejecting negatives

   Name every `CHECK` and `UNIQUE` constraint.

5. **Add one cross-column `CHECK`.** The purchase order has a raised date and an expected date.
   Write the constraint that stops the expected date preceding the raised date, and name it.

6. **Write `seed.sql`.** Enough rows to exercise the model: at least two suppliers, one product
   available from two suppliers at different prices, two warehouses, one product stocked in
   neither, one purchase order part-received across two deliveries, one delivery that was short.

   Use `RETURNING` or explicit ids consistently — do not assume a generated id.

7. **Run the rebuild twice.**

   ```bash
   chmod +x rebuild.sh && ./rebuild.sh && ./rebuild.sh
   ```

   Both runs must succeed with identical output. If the second fails, the script is not
   repeatable — fix it now, because every assessment in this module runs it from clean.

8. **Produce constraint evidence.** Create `constraints_evidence.sql` containing one statement
   per constraint that *must fail*, each with the expected error as a comment:

   ```sql
   -- Expect: violates check constraint "po_line_quantity_positive"
   INSERT INTO purchase_order_line (po_id, product_id, quantity) VALUES (900, 1, 0);
   ```

   Capture the real output:

   ```bash
   psql orderdesk_supply -f constraints_evidence.sql > evidence.txt 2>&1
   ```

9. **Justify the referential actions.** In `docs/constraints.md`, one line per foreign key
   naming the action chosen and the domain reason. At least one must be `RESTRICT` and at
   least one `CASCADE`, and both must be defensible.

## Acceptance

- [ ] `./rebuild.sh` succeeds twice in a row from a clean database.
- [ ] `schema.sql` drops in reverse dependency order and creates in dependency order.
- [ ] Every foreign key names an explicit `ON DELETE` action.
- [ ] Every enumerated column has a named `CHECK` listing its values.
- [ ] Money columns are `numeric`, instants are `timestamptz`; no `float`, no bare `timestamp`.
- [ ] The cross-column date `CHECK` exists and is named.
- [ ] `seed.sql` includes a part-received purchase order and a short delivery.
- [ ] `evidence.txt` shows a real error for every constraint claimed.
- [ ] `docs/constraints.md` justifies every referential action in domain terms.

> **Note.** A constraint with no failing statement beside it is a constraint nobody has
> tested. Several of them will not do what you expect the first time.

---

Next: [SQL Querying, Plans & Transactions](querying-plans-and-transactions.md).
