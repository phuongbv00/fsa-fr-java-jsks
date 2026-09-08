# Lab 04 — Services, transactions and an invariant

**Duration:** 180 min · **Objectives:** SBAD-K2

## Objectives

After this lab, learners can:

- Move business rules out of controllers into services.
- Apply `@Transactional` at the right boundary and prove rollback.
- Enforce an invariant spanning several rows.
- Choose and demonstrate a locking strategy.

## Before you start

- You have read [Service Layer, Transactions & Locking](services-and-transactions.md).
- Lab 03 is complete.

## Steps

1. **Add a `stock` table** with `product_id`, `on_hand`, `reserved` and a `version` column, plus
   a `CHECK` that reserved never exceeds on hand.

2. **Move the rules.** Any conditional logic left in a controller moves to a service. Record in
   `docs/layers.md` what moved and why the controller is better without it.

3. **Implement `place`** transactionally: validate the customer, resolve every SKU, reject
   inactive products, check stock, reserve it, and save the order.

4. **Prove atomicity.** A request whose third line is out of stock must leave no order row and
   no reservation. Write the test that asserts both counts are unchanged.

5. **Demonstrate the checked-exception default.** Make one failure a checked exception without
   `rollbackFor`, show the partial commit in a test, then add `rollbackFor` and show it fixed.
   Record both in `docs/transactions.md`.

6. **Demonstrate self-invocation.** Add `placeAll` calling `this.place(...)` in a loop. Show
   that a failure part-way leaves earlier orders committed. Explain why, then fix it and show
   the corrected behaviour.

7. **Demonstrate a lost update.** Two threads reserve the same product concurrently with no
   locking. Record the resulting `on_hand` and show it is wrong.

8. **Fix it optimistically.** Add `@Version`, retry on `OptimisticLockingFailureException` with
   a bounded loop, and show the corrected total.

9. **Fix it pessimistically.** Add a `PESSIMISTIC_WRITE` query and show the corrected total that
   way too.

10. **Compare.** In `docs/transactions.md`, contrast the two under low and high contention, and
    say which you would ship for this endpoint and why.

## Acceptance

- [ ] No controller contains a business rule.
- [ ] `@Transactional` is on service methods; queries use `readOnly = true`.
- [ ] The atomicity test proves no order and no reservation survive a mid-way failure.
- [ ] The checked-exception demonstration shows the partial commit and its fix.
- [ ] The self-invocation demonstration shows the bypass and its fix.
- [ ] The lost-update demonstration records a wrong `on_hand`.
- [ ] Both optimistic and pessimistic fixes are implemented and produce the correct total.
- [ ] `docs/transactions.md` compares them and justifies a choice.

---

Next: [Validation & Error Contracts](validation-and-error-contracts.md).
