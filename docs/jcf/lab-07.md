# Lab 07 — A JDBC repository with integration tests

**Duration:** 150 min

## Objectives

By the end of this lab you will be able to:

- Implement a repository interface against a real database with JDBC.
- Use `PreparedStatement` and try-with-resources correctly.
- Control a transaction explicitly and prove the rollback path.

## Before you start

- You have read [JDBC & the Repository Pattern](jdbc-and-repositories.md).
- Your OrderDesk database from Database Foundations rebuilds with `./rebuild.sh`.
- Lab 06 is complete.

## Steps

1. **Add the dependencies.** PostgreSQL driver at `runtime` scope, HikariCP at `compile`. Read
   the database password from an environment variable — a literal in source fails this lab.

2. **Define the interface.** `OrderRepository` with `findById`, `findByCustomer`, `save` and
   `placeOrder(Order)` which writes an order and all its lines.

3. **Write `InMemoryOrderRepository`** first, and run your existing service tests against it.
   They must pass with no database running.

4. **Implement `JdbcOrderRepository`.** Every value bound through `?`. Every `Connection`,
   `PreparedStatement` and `ResultSet` inside try-with-resources. Columns read by name.

5. **Handle nullable columns.** At least one column in your query is nullable — read it so that
   null stays null, and test it.

6. **Translate exceptions.** No `SQLException` escapes. Wrap in `RepositoryException` with the
   cause and a message naming what was being done.

7. **Implement `placeOrder` transactionally.** One connection, `setAutoCommit(false)`,
   `commit()` on success, `rollback()` in `catch`, auto-commit restored in `finally`.

8. **Prove the rollback.** Write a test that places an order whose second line violates a
   constraint, then asserts the order row count is unchanged. This test is the point of the
   lab — without it nothing shows the transaction works.

9. **Prove injection is prevented.** Write a test passing `1 OR 1=1` where a value is expected,
   asserting it returns nothing or throws rather than returning every row. Record it in
   `docs/jdbc.md`.

10. **Show a leak, then fix it.** Temporarily rewrite one method without try-with-resources,
    run a loop of 100 failing calls against a pool of size 5, and record the hang or timeout in
    `docs/jdbc.md`. Restore the correct version.

## Acceptance

- [ ] Service tests pass against `InMemoryOrderRepository` with no database running.
- [ ] `JdbcOrderRepository` passes the same interface-level tests against PostgreSQL.
- [ ] No string concatenation of values into SQL anywhere.
- [ ] Every JDBC resource is in a try-with-resources; the leak demonstration is restored.
- [ ] A nullable column reads as null, with a test.
- [ ] `SQLException` never escapes; `RepositoryException` always carries the cause.
- [ ] The rollback test proves no rows survive a failed `placeOrder`.
- [ ] `docs/jdbc.md` records the injection attempt and the pool-exhaustion demonstration.
- [ ] No credential appears in any tracked file.

---

Next: [JPA & Hibernate Mapping](jpa-and-hibernate.md).
