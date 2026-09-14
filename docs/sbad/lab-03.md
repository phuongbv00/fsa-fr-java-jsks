# Lab 03 — Repositories, queries and projections

**Duration:** 150 min

## Objectives

By the end of this lab you will be able to:

- Declare repositories and write derived and explicit queries.
- Return pages and projections instead of whole entity lists.
- Detect and fix an N+1 introduced by a derived query.

## Before you start

- You have read [Spring Data JPA](spring-data-jpa.md).
- Lab 02 is complete.

## Steps

1. **Declare the repositories** for `Order`, `Product` and `Customer`, extending
   `JpaRepository`. Write no implementation class.

2. **Write six derived queries**, each used by an endpoint: by customer; by status; by customer
   and status; placed between two instants; the most recent order for a customer; a count by
   status.

3. **Break one deliberately.** Misspell a property in a method name, start up, and paste the
   `No property ... found` error into `docs/queries.md`. Explain why a startup failure is
   better than a runtime one.

4. **Convert one to `@Query`.** Take the derived method whose name is least readable, rewrite it
   as JPQL with `@Param`, and record both versions side by side with one sentence on why the
   second is better.

5. **Add a projection.** A record projection returning order id, placed date and computed total,
   in one query, with no entities loaded.

6. **Paginate two endpoints** with `Page`, including a unique tie-break.

7. **Seed 200 orders** for one customer, each with several lines.

8. **Measure the N+1.** Enable `hibernate.generate_statistics`. Write a test calling the history
   endpoint's service method and printing the query count. Record the number.

9. **Fix it** with a fetch join and an explicit `countQuery`. Re-measure, and change the test to
   assert the count so a regression fails the build.

10. **Compare with a projection.** Measure the projection version's query count too, and say in
    `docs/queries.md` when you would choose each.

## Acceptance

- [ ] No repository implementation class exists in the source tree.
- [ ] Six derived queries exist and are used by endpoints.
- [ ] `docs/queries.md` records the property-name startup failure and explains it.
- [ ] One query is converted to `@Query` with `@Param`, with both versions shown.
- [ ] A record projection returns a computed total in one query.
- [ ] Two endpoints return `Page` with a unique tie-break.
- [ ] Before and after query counts are recorded for at least 200 orders.
- [ ] The fetch-joined `Page` has an explicit `countQuery`.
- [ ] A test asserts the query count and would fail on regression.

---

Next: [Service Layer, Transactions & Locking](services-and-transactions.md).
