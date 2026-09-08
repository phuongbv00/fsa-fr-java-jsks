# Story A — refuse returns on final-clearance items

**Ticket:** ODK-141

> As a **refunds clerk**
> I want returns on final-clearance items to be refused when the return is opened
> So that I do not approve refunds the business has already said it will not honour

## Acceptance criteria

- Opening a return whose lines are all final-clearance is refused, and the refusal names
  final clearance as the reason.
- Opening a return with a mix of final-clearance and normal lines succeeds, and covers only
  the normal lines.
- Opening a return with no final-clearance lines behaves exactly as it does today.
- The refusal is a thrown error, consistent with how `openReturn` already rejects an empty
  line list.

## Notes

An order line carries `finalClearance: true` when it was sold on final clearance. Assume the
flag is present on every line.

Your change belongs in `openReturn` in `src/returns.js`. Branch from `main` as
`feature/odk-141-final-clearance`.
