# Lab 04 — Interchangeable strategies behind one interface

**Duration:** 120 min

## Objectives

By the end of this lab you will be able to:

- Declare an interface expressing a capability in domain terms.
- Implement it several ways and substitute one for another without changing callers.
- Replace conditional logic with polymorphism.

## Before you start

- You have read [Interfaces, Polymorphism & Composition](interfaces-and-polymorphism.md).
- Lab 03 is complete; you have `Order`, `Money` and `OrderStatus`.

## The brief

OrderDesk charges shipping by policy, and the policy varies by customer and season:

| Policy | Cost | Promised date |
|---|---|---|
| Standard | 25 000 VND, free over 500 000 | placed + 5 days |
| Express | 80 000 VND, never free | placed + 1 day |
| Pickup | 0 | placed + 2 days |

## Steps

1. **Start from the wrong version.** Write `Checkout.shippingCost(Order, String tier)` as one
   method with an `if`/`else` chain over all three policies. Commit it. This is the baseline
   you will argue against.

2. **Extract the interface.** Define `ShippingPolicy` with `cost(Order)` and
   `promise(Instant)`.

3. **Implement all three** as separate final classes. Each holds its own constants.

4. **Rewrite `Checkout`** to take a `ShippingPolicy` in its constructor and hold it `final`.
   Its methods must contain no conditional over policy type.

5. **Test substitution.** One test constructs `Checkout` with each policy and asserts the cost
   and the promised date. The test body must be identical apart from the policy.

6. **Test the boundary.** Standard shipping is free over 500 000 — assert at 499 999, 500 000
   and 500 001, and say in a comment which side the boundary falls on.

7. **Add a fourth policy without touching `Checkout`.** Overnight: 150 000 VND, placed + 0 days.
   Commit separately, and in `docs/strategy.md` show the diff — it must not include `Checkout`.

8. **Add a no-op discount.** Define `DiscountPolicy` with a `NONE` constant, and make `Checkout`
   take one. Show a test passing `NONE` rather than null.

9. **Write the comparison.** In `docs/strategy.md`, contrast the step-1 version with the final
   one: what changes when a policy is added, and which file each version touches.

## Acceptance

- [ ] `ShippingPolicy` is an interface with four implementations.
- [ ] `Checkout` contains no `if`, `switch` or `instanceof` over policy type.
- [ ] The substitution test differs only in the policy constructed.
- [ ] Boundary tests cover 499 999, 500 000 and 500 001 with a stated convention.
- [ ] Adding the fourth policy touched no existing class, shown by the diff.
- [ ] `DiscountPolicy.NONE` exists and no code path accepts a null policy.
- [ ] `docs/strategy.md` compares the two designs by what has to change.

---

Next: [Exceptions & Unit Testing](exceptions-and-testing.md).
