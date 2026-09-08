# Lab 04 — Forms, validation and mutations

**Duration:** 150 min

## Objectives

By the end of this lab you will be able to:

- Build controlled inputs with typed form state.
- Validate on the client and display server field errors.
- Handle a mutation's pending, success and failure states.

## Before you start

- You have read [Forms, Validation & Mutations](forms-and-mutations.md).
- Lab 03 is complete.

## Steps

1. **Build `NewOrderPage`** with a customer field and a repeatable list of order lines that can
   be added and removed.

2. **Use one typed form state object** holding strings, updated immutably.

3. **Demonstrate the uncontrolled warning.** Initialise a field as `undefined`, type into it,
   record the React warning, then fix it with `''`.

4. **Write `validate`** returning errors keyed by the **same paths** the API uses —
   `customerId`, `lines[0].sku`, `lines[0].quantity`.

5. **Show errors after blur**, not while typing, and reveal all of them on a failed submit.

6. **Wire accessibility:** `aria-invalid`, `aria-describedby` pointing at the message, and
   `role="alert"` on the summary. Verify with the accessibility tree and screenshot it.

7. **Submit as a mutation** with a `SubmitState` union covering idle, submitting, error and
   success. Disable the button and change its label while in flight.

8. **Demonstrate the double submit.** Remove the disabled state, throttle the network, double
   click, and record two orders created. Restore it and record one.

9. **Display server field errors.** Post a body the client accepts but the server rejects —
   an unknown SKU, or a quantity above the server's maximum — and show the message appearing
   next to the right field. Screenshot it.

10. **Keep the list in step.** After cancelling an order from the list, show the row updating.
    Implement it once with a refetch and once optimistically with rollback, and compare the two
    in `docs/forms.md`.

## Acceptance

- [ ] Form state is one typed object of strings, updated immutably.
- [ ] The uncontrolled-input warning is demonstrated and fixed.
- [ ] Client error keys match the API's `fieldErrors[].field` paths.
- [ ] Errors appear on blur and all appear on a failed submit.
- [ ] `aria-invalid`, `aria-describedby` and `role="alert"` are wired, with a screenshot.
- [ ] `SubmitState` covers four cases; the button is disabled and relabelled while submitting.
- [ ] The double-submit demonstration shows two orders, then one.
- [ ] A server field error is shown against the correct field, screenshotted.
- [ ] Both refetch and optimistic update are implemented and compared.

---

Next: [Authentication, Authorization & Shared State](auth-and-shared-state.md).
