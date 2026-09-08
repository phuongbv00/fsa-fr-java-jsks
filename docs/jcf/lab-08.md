# Lab 08 — The same repository with JPA

**Duration:** 150 min

## Objectives

By the end of this lab you will be able to:

- Map entities and relationships onto an existing schema.
- Identify and set the owning side of a relationship.
- Implement repository operations with `EntityManager` and JPQL.
- Manage transactions around JPA operations.

## Before you start

- You have read [JPA & Hibernate Mapping](jpa-and-hibernate.md).
- Lab 07 is complete, including its interface-level test suite.

## Steps

1. **Add Hibernate 7.1 and Jakarta Persistence 3.2.** Configure `persistence.xml` with
   `hbm2ddl.auto=validate` — the schema stays owned by the supplied SQL scripts — and turn
   `show_sql` and `format_sql` on now. The password is passed to
   `Persistence.createEntityManagerFactory` from the environment, never written in the file.

2. **Map `Order` and `OrderLine`** onto the existing tables. The table is `orders`, not `order`.
   Status goes through an `AttributeConverter` that writes `dbValue()` and reads with `fromDb`.
   Every column name is explicit.

   Try `@Enumerated(EnumType.STRING)` first, save an order, and paste the `orders_status_known`
   violation into `docs/jpa.md` with one sentence on why `validate` did not catch it.

3. **Let `validate` catch you.** Deliberately misname one column, start up, and paste the
   `SchemaManagementException` into `docs/jpa.md` with one sentence on what it prevented. Fix it.

4. **Map the relationship.** `OrderLine.order` is `@ManyToOne` and `LAZY`; `Order.lines` is
   `@OneToMany(mappedBy = "order")` with cascade and orphan removal.

5. **Demonstrate ownership.** Write `addLine` so that it only adds to the collection and does
   not call `line.setOrder(this)`. Persist an order with one line and record what happens —
   a `NOT NULL` violation on `order_id`, because the owning side was never set. Then complete
   the helper so it sets both sides and show the same test passing.

6. **Implement `JpaOrderRepository`** against the same `OrderRepository` interface, using JPQL
   with named parameters. Lookups return `Optional`, never throw `NoResultException`.

7. **Run the same tests.** Your lab 07 interface-level suite must pass unchanged against the JPA
   implementation. Any test that needs changing is a test coupled to JDBC — fix the test.

8. **Manage the transaction.** `save` begins, commits, and rolls back on failure with the
   transaction checked for activity first.

9. **Demonstrate dirty checking.** Load an order, change its status without calling `save`, and
   commit. Show from the SQL log that an `UPDATE` was issued. Then repeat after the context
   closes and show that nothing is written. Record both in `docs/jpa.md`.

10. **Keep both implementations.** Do not delete `JdbcOrderRepository`; it is the evidence that
    the interface was worth having, and lab 09 compares them.

## Acceptance

- [ ] `hbm2ddl.auto=validate`, and `docs/jpa.md` shows a real validation failure it caught.
- [ ] Status is mapped through a converter, and `docs/jpa.md` shows the `CHECK` violation that
      `EnumType.STRING` causes.
- [ ] Associations are `LAZY`; no `EAGER` appears in the mapping.
- [ ] The ownership demonstration shows the inverse-only helper failing, then the complete one
      working.
- [ ] `JpaOrderRepository` passes the unchanged lab 07 interface tests.
- [ ] Lookups return `Optional`; `NoResultException` never reaches a caller.
- [ ] The dirty-checking demonstration shows an `UPDATE` in the log, and nothing when detached.
- [ ] Both repository implementations are present and both test suites pass.

---

Next: [Persistence Performance](persistence-performance.md).
