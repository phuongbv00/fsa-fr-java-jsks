# Lab 03 — Query, index and transact

**Duration:** 120 min

## Objectives

By the end of this lab you will be able to:

- Write queries spanning joins, grouping, aggregation and subqueries, and validate the results.
- Read a query plan and identify wasted work.
- Justify one index with plan evidence captured before and after.
- Demonstrate commit and rollback, and observe a concurrency anomaly.

## Before you start

- You have read [SQL Querying, Plans & Transactions](querying-plans-and-transactions.md).
- Lab 02 is complete and `./rebuild.sh` succeeds.
- You can open **two** `psql` sessions against the same database at once.

## Steps

1. **Grow the data.** Plans on ten rows tell you nothing — the planner will scan, correctly.
   Add a bulk load to `seed_bulk.sql`:

   ```sql
   INSERT INTO purchase_order (supplier_id, raised_by, raised_at, expected_at, state)
   SELECT 1, 1, now() - (n || ' days')::interval,
          now() - (n || ' days')::interval + interval '7 days', 'closed'
   FROM   generate_series(1, 50000) AS n;
   ```

   Adapt it to your schema, then load enough purchase order lines that the table exceeds
   100 000 rows.

2. **Write the query set.** In `queries.sql`, one numbered query each, with a comment stating
   in words what it must return:

   1. Every supplier with the number of purchase orders raised against them, including
      suppliers with none.
   2. Products stocked in no warehouse at all.
   3. For each warehouse, the total units on hand and the number of distinct products, for
      warehouses holding more than 100 units in total.
   4. Purchase orders that are part-received: some delivery exists, but at least one line is
      short of its ordered quantity.
   5. The three products with the highest total ordered quantity in the last 30 days.
   6. For each supplier, their cheapest offered product and its price.

3. **Validate each result.** For every query, say how you know it is right. A count you can
   verify by hand on the seed data, a row you can point at, or a deliberate counter-example.
   Put this in `docs/queries.md` — one paragraph per query. "It returned rows" is not validation.

4. **Find the slow one.** Run `EXPLAIN ANALYZE` over each query. Identify the one with the
   largest `Rows Removed by Filter`, and save its plan to `docs/plan_before.txt`.

5. **Add exactly one index.** Choose it from the plan, not from intuition. Save the statement
   in `index.sql` with a comment naming the plan line that motivated it:

   ```sql
   -- Motivated by: "Seq Scan on purchase_order_line ... Rows Removed by Filter: 149 997"
   CREATE INDEX idx_po_line_po_id ON purchase_order_line (po_id);
   ```

6. **Capture the after-plan.**

   ```bash
   psql orderdesk_supply -f index.sql
   psql orderdesk_supply -c "ANALYZE;"
   psql orderdesk_supply -c "EXPLAIN ANALYZE <your query>" > docs/plan_after.txt
   ```

   In `docs/index.md`, quote the scan-type line from each plan side by side and state the
   change in `Rows Removed by Filter` and `Execution Time`.

7. **Demonstrate rollback.** In `docs/transactions.md`, capture a session transcript showing an
   `UPDATE` with no `WHERE`, the row count it reports, and a `ROLLBACK` — then a `SELECT`
   proving nothing changed.

8. **Observe an anomaly.** With two sessions side by side, reproduce the non-repeatable read
   from the note against your own tables. Record both sessions' statements in order, with the
   two different values session A read. Then repeat it under `REPEATABLE READ` and record what
   differs.

## Acceptance

- [ ] The largest table exceeds 100 000 rows.
- [ ] All six queries in `queries.sql` run and each carries a comment saying what it must return.
- [ ] Query 1 includes suppliers with zero purchase orders; query 2 uses an anti-join or `NOT EXISTS`.
- [ ] Query 3 filters groups with `HAVING`, not `WHERE`.
- [ ] `docs/queries.md` validates each result with a concrete check, not "it looked right".
- [ ] `docs/plan_before.txt` and `docs/plan_after.txt` exist and cover the same query.
- [ ] `index.sql` creates exactly one index and cites the plan line that motivated it.
- [ ] `docs/index.md` shows the scan type changing and quotes both execution times.
- [ ] `docs/transactions.md` shows a rollback undoing an unqualified `UPDATE`.
- [ ] The anomaly transcript shows two different values read inside one transaction, and what
      `REPEATABLE READ` changes.

> **Tip.** If the index makes no difference, that is a finding, not a failure — provided you
> can say why from the plan. Report it honestly; an index that does nothing is worth knowing
> about.

---

Next: [Database Foundations — Appendix](appendix.md).
