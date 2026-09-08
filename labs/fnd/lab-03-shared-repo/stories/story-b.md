# Story B — refuse returns outside the 30-day window

**Ticket:** ODK-152

> As a **refunds clerk**
> I want returns opened more than 30 days after delivery to be refused
> So that the policy is enforced when the return is raised, not after I have already promised
> the customer a refund

## Acceptance criteria

- Opening a return more than 30 days after the order's `deliveredAt` is refused, and the
  refusal names the window as the reason.
- Opening a return on day 30 exactly is allowed. Day 31 is not.
- An order with no `deliveredAt` — nothing delivered yet — is allowed, since the window has
  not started.
- The refusal is a thrown error, consistent with how `openReturn` already rejects an empty
  line list.

## Notes

The window runs from delivery, not from the order date. The returns policy in `docs/` says so;
the website says "one month", which is a separate problem and not yours to fix here.

Your change belongs in `openReturn` in `src/returns.js`. Branch from `main` as
`feature/odk-152-return-window`.
