# Story D — refuse returns against a cancelled order

**Ticket:** ODK-170

> As a **refunds clerk**
> I want returns against a cancelled order to be refused
> So that we do not refund an order the customer was never charged for

## Acceptance criteria

- Opening a return against an order whose status is `cancelled` is refused, and the refusal
  says the order was cancelled.
- Opening a return against any other status behaves as it does today.
- A cancelled order is refused even when the lines being returned are otherwise valid.
- The refusal is a thrown error, consistent with how `openReturn` already rejects an empty
  line list.

## Notes

An order carries `status`, one of `placed`, `picking`, `dispatched`, `delivered`, `cancelled`.

Your change belongs in `openReturn` in `src/returns.js`. Branch from `main` as
`feature/odk-170-cancelled-order`.
