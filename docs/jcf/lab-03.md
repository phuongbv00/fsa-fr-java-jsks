# Lab 03 — Model the OrderDesk domain

**Duration:** 120 min

## Objectives

By the end of this lab you will be able to:

- Design classes whose constructors make invalid instances impossible.
- Choose between `record`, `enum` and `class` for a given concept.
- Implement `equals` and `hashCode` consistently and prove it.

## Before you start

- You have read [Object-Oriented Design & Modern Java Types](objects-and-modern-types.md).
- Lab 02 is complete.

## The brief

Model the OrderDesk order domain in `com.fsa.orderdesk.domain`, enforcing these rules from
Database Foundations:

- An order line has a positive quantity and a non-negative unit price.
- A SKU matches two uppercase letters, a hyphen and two digits.
- Money has an amount and a currency; adding different currencies is an error.
- An order is `PLACED`, `PICKING`, `DISPATCHED`, `DELIVERED` or `CANCELLED`.
- Lines may be added only while the order is `PLACED`.
- An order may be cancelled only from `PLACED` or `PICKING`.
- Two orders are the same if their ids are the same, whatever their contents.

## Steps

1. **Classify each concept.** In `docs/design.md`, a table of `Sku`, `Money`, `OrderStatus`,
   `OrderLine`, `Order` with the chosen kind (`record`, `enum`, `class`) and one line of
   justification each.

2. **Implement `Sku` as a record** with a compact constructor rejecting a malformed value. Test
   three malformed inputs and one valid one.

3. **Implement `Money` as a record** with `plus`, `times` and a comparison. Adding a different
   currency throws, and the message names both currencies.

4. **Implement `OrderStatus` as an enum** with `dbValue()`, a `fromDb` that throws on unknown
   input, and a `canBeCancelled()` used by `Order`.

5. **Implement `OrderLine`** validating in the constructor, with no setters and a `lineTotal()`.

6. **Implement `Order`** as a class enforcing the state rules, exposing `lines()` as an
   unmodifiable view, with `equals`/`hashCode` on id only.

7. **Prove the encapsulation.** Write a test asserting that mutating the list returned by
   `lines()` throws, and does not change the order.

8. **Prove the hash contract.** Write a test that puts an `Order` in a `HashSet` and finds it
   again with an equal-but-different instance. Then, in `docs/design.md`, describe what happens
   if `hashCode` is removed — and confirm it by removing it temporarily.

## Acceptance

- [ ] `docs/design.md` justifies the kind chosen for all five concepts.
- [ ] `Sku` rejects malformed values in its compact constructor, with tests.
- [ ] `Money.plus` rejects a currency mismatch and names both currencies.
- [ ] `OrderStatus.fromDb` throws on an unknown value rather than returning null.
- [ ] `OrderLine` and `Order` validate in the constructor and expose no setters.
- [ ] `order.addLine` throws when the order is not `PLACED`; `cancel` throws when not cancellable.
- [ ] `lines()` returns an unmodifiable view, proved by a test.
- [ ] A `HashSet` test finds an equal instance, and `docs/design.md` records what breaks without
      `hashCode`.

---

Next: [Interfaces, Polymorphism & Composition](interfaces-and-polymorphism.md).
