# Story E — refuse returns before anything has been delivered

**Ticket:** ODK-178

> As a **refunds clerk**
> I want a return to be refused when nothing has been delivered yet
> So that customers cancel instead of returning goods that are still in our warehouse

## Acceptance criteria

- Opening a return against an order with no `deliveredAt` is refused, and the refusal
  suggests cancelling instead.
- Opening a return against a delivered order behaves as it does today.
- An order that is partly delivered — it has a `deliveredAt` — is allowed, even if some
  shipments are still out.
- The refusal is a thrown error, consistent with how `openReturn` already rejects an empty
  line list.

## Notes

`order.deliveredAt` is an ISO-8601 string, or `null` when nothing has arrived yet.

This overlaps with the cancellation rule you met in the study guide: the cancellation window
closes at first dispatch, so there is a gap where an order can be neither cancelled nor
returned. Note that in your pull request — it is a real question for the product owner, not
something to fix here.

Your change belongs in `openReturn` in `src/returns.js`. Branch from `main` as
`feature/odk-178-not-yet-delivered`.
