# Lab 06 — Lookup, grouping, sorting and reporting

**Duration:** 150 min

## Objectives

By the end of this lab you will be able to:

- Choose a collection from the access pattern a task needs.
- Build lookup, grouping and sorting operations with streams.
- Demonstrate why hash collections need consistent equality.

## Before you start

- You have read [Collections, Generics, Lambdas & Streams](collections-and-streams.md).
- Lab 05 is complete; you have `Order`, `OrderLine`, `Product` and a catalog loader.

## Steps

1. **Justify the collections.** In `docs/collections.md`, for each of these say which type you
   chose and why: the catalog indexed by SKU; the set of SKUs already seen; the ordered list of
   an order's lines; a report keyed by status in a stable order.

2. **Build the index.** `Map<Sku, Product> bySku` from a `List<Product>` with
   `Collectors.toMap`. Supply a merge function and state in a comment what a duplicate SKU
   means for the catalog.

3. **Prove the duplicate case.** Write a test with two products sharing a SKU, asserting the
   documented behaviour rather than whatever happens.

4. **Implement six operations** in `OrderReports`, each with a test:

   1. Total units across a list of orders.
   2. Orders grouped by status.
   3. A count per status, in one pass.
   4. The distinct SKUs appearing in any order.
   5. Orders sorted by status then by placed date descending.
   6. The top *n* customers by lifetime value, excluding cancelled orders.

5. **Make the sort stable.** Operation 5 and 6 must have a documented tie-break, and a test with
   two equal entries asserting a deterministic order.

6. **Demonstrate the hash contract.** Write a test that adds an `Order` to a `HashSet`, mutates
   a field feeding `hashCode`, and shows `contains` returning false. Record the output in
   `docs/collections.md` and explain it.

7. **Compare the costs.** Implement "SKUs seen so far" twice — once with `List.contains`, once
   with a `HashSet` — over 50 000 items. Time both, record the numbers, and explain the
   difference in complexity terms.

8. **Remove correctly.** Write a method dropping cancelled orders from a mutable list. Show the
   version that throws `ConcurrentModificationException` in `docs/collections.md`, then the
   `removeIf` version that works.

## Acceptance

- [ ] `docs/collections.md` justifies four collection choices by access pattern.
- [ ] `Collectors.toMap` has a merge function whose behaviour is tested.
- [ ] All six operations exist with tests asserting concrete values.
- [ ] Sorted operations have a tie-break and a test proving determinism.
- [ ] The hash-contract test shows `contains` failing after mutation, and is explained.
- [ ] Timings for `List.contains` versus `HashSet.contains` are recorded with the complexity.
- [ ] Both the failing and the working removal are shown, with the exception named.
- [ ] No stream in the solution mutates a collection outside itself.

---

Next: [JDBC & the Repository Pattern](jdbc-and-repositories.md).
