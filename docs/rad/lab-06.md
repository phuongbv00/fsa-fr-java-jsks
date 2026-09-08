# Lab 06 — Tests, an error boundary and a production build

**Duration:** 150 min

## Objectives

By the end of this lab you will be able to:

- Write component tests querying by role and label.
- Mock the network and test all four states.
- Add an error boundary and ship a configured production build.

## Before you start

- You have read [Testing, Error Boundaries & the Production Build](testing-and-production.md).
- Lab 05 is complete.

## Steps

1. **Install** Vitest, Testing Library, `jest-dom`, `user-event` and MSW. Configure `jsdom` and a
   setup file.

2. **Write pure component tests** for `StatusBadge`, `OrdersTable` and `OrderFilters`, querying
   only by role, label and text.

3. **Demonstrate why role queries matter.** Change a `<button>` to a clickable `<div>`, record
   the test failing, and explain what real bug that failure represents. Revert.

4. **Mock the API with MSW** and test `OrdersPage` in all four states: loading, empty, success
   and error.

5. **Test the form.** Fill it with `userEvent`, submit, and assert both a client validation error
   and a mocked server field error appearing against the right field.

6. **Test the auth flow** end to end: sign in, see orders, cancel one — every query by label or
   role.

7. **Test a protected route:** rendering it signed out redirects to login.

8. **Add an error boundary** at the root. Write a component that throws during render, show the
   blank page without the boundary and the message with it. Screenshot both.

9. **Say what it does not catch.** Throw from an event handler, record that the boundary does not
   catch it, and write the correct handling in `docs/testing.md`.

10. **Configure environments.** `.env.development` and `.env.production` with `VITE_API_URL`; no
    secrets. Prove the prefix rule by adding a non-prefixed variable and showing it is undefined
    in the client.

11. **Build and preview.** `npm run build`, record the bundle sizes, run `npm run preview`, and
    confirm the app works against the real API.

12. **Prove no secret was bundled** by grepping `dist/assets/*.js`, and record the result.

## Acceptance

- [ ] Vitest and Testing Library run with `npm test`.
- [ ] Every query is by role, label or text; no class or test-id selectors where a role exists.
- [ ] The `div`-instead-of-`button` failure is demonstrated and explained.
- [ ] All four states of `OrdersPage` are tested with MSW.
- [ ] A form test asserts both a client and a server field error.
- [ ] The auth flow and a protected-route redirect are tested.
- [ ] The error boundary demonstration is screenshotted with and without.
- [ ] `docs/testing.md` records what the boundary does not catch and the correct handling.
- [ ] Environment files exist with no secrets; the `VITE_` prefix rule is demonstrated.
- [ ] Bundle sizes are recorded and `npm run preview` works against the real API.
- [ ] The `dist/` secret grep is recorded as clean.

---

Next: [React Application Development — Appendix](appendix.md).
