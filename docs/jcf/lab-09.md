# Lab 09 — Diagnose and fix an N+1

**Duration:** 120 min

## Objectives

By the end of this lab you will be able to:

- Read a Hibernate SQL log and count the statements a call issues.
- Recognise N+1 from the log and name the line that caused it.
- Correct it with a fetch join and verify with a query count.
- Explain why making an association eager is not the fix.

## Before you start

- You have read [Persistence Performance](persistence-performance.md).
- Lab 08 is complete and `JpaOrderRepository` passes its tests.

## Steps

1. **Seed enough data.** At least 200 orders for one customer, each with 2 to 5 lines. Ten
   orders will not show the problem — that is why it survives testing.

2. **Turn on statistics.** Add `hibernate.generate_statistics`, and bind-parameter logging.

3. **Write the measuring test.** Call `findByCustomer`, touch `order.lines()` for every result,
   and print `getPrepareStatementCount()`. Record the number in `docs/nplus1.md`.

4. **Capture the log.** Save the first 20 lines of SQL to `docs/log_before.txt`. Annotate it:
   which statement is the "1" and which is the "N".

5. **Name the cause.** In `docs/nplus1.md`, one sentence naming the *line of Java* that caused
   it — not "lazy loading". Lazy loading is correct; the defect is where the collection is
   touched.

6. **Fix it with a fetch join.** Rewrite the query with `LEFT JOIN FETCH`. Explain in a comment
   why `LEFT` rather than plain `JOIN`, and why the SQL fan-out does not give you each order
   three times.

7. **Verify.** Re-run the measuring test. Change its assertion to `assertEquals(1, queries)` so
   it fails if anyone reintroduces the lazy path. Save `docs/log_after.txt`.

8. **Try the wrong fix.** Temporarily set the association to `EAGER`. Re-run the *whole* test
   suite and record what happens to the query counts of tests that never touch lines. Revert it,
   and write two sentences in `docs/nplus1.md` on why it is the wrong fix.

9. **Try a projection.** Add a read-only `OrderSummary` query returning id, date and total in
   one statement, with no entities. Record its query count and compare with the fetch join.

10. **Report.** `docs/nplus1.md` must contain: before and after counts, the two log extracts,
    the cause, the fix, why eager is wrong, and when a projection is preferable.

## Acceptance

- [ ] At least 200 orders are seeded, with a variable number of lines each.
- [ ] `docs/log_before.txt` shows one parent query and many child queries, annotated.
- [ ] The cause names the Java line, not "lazy loading".
- [ ] The fixed query uses `LEFT JOIN FETCH`, with `LEFT` and the absence of duplicates explained.
- [ ] The measuring test asserts a query count and would fail on regression.
- [ ] `docs/log_after.txt` shows a single statement.
- [ ] The eager experiment is recorded, reverted, and argued against.
- [ ] The projection query count is recorded and compared.

---

Next: [Java Core, JDBC & JPA/Hibernate — Appendix](appendix.md).
