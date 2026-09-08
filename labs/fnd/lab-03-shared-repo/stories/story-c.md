# Story C — refuse returning more units than were ordered

**Ticket:** ODK-163

> As a **refunds clerk**
> I want a return to be refused when it claims more units than the order contained
> So that a typo in the quantity does not become a refund for goods we never sent

## Acceptance criteria

- Opening a return for a quantity greater than the matching order line's quantity is refused,
  and the refusal names the SKU and both quantities.
- Opening a return for exactly the ordered quantity succeeds.
- Opening a return for fewer than the ordered quantity succeeds — partial returns are normal.
- A returned line whose SKU is not on the order at all is refused.
- The refusal is a thrown error, consistent with how `openReturn` already rejects an empty
  line list.

## Notes

Each entry in `lines` carries a `sku` and a `quantity`, and `order.lines` carries the same
shape. Match on SKU.

Your change belongs in `openReturn` in `src/returns.js`. Branch from `main` as
`feature/odk-163-quantity-check`.
