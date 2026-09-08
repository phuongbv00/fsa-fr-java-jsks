# Lab 05 — Session state and protected routes

**Duration:** 150 min · **Objectives:** RAD-K3

## Objectives

After this lab, learners can:

- Share session state with context.
- Attach the token centrally and handle expiry.
- Protect routes and return the user to where they were going.

## Before you start

- You have read [Authentication, Authorization & Shared State](auth-and-shared-state.md).
- Lab 04 is complete, and your API issues JWTs.

## Steps

1. **Build `AuthContext` and `AuthProvider`** holding token and user, with `login` and `logout`,
   and a `useAuth` hook that throws a clear error outside the provider.

2. **Prove the error message helps.** Render a consumer outside the provider, record the message,
   and compare it in `docs/auth.md` with what you would see without the guard.

3. **Memoise the context value.** Demonstrate the re-render storm without `useMemo` using React
   DevTools' highlight-updates, screenshot it, then fix it and screenshot again.

4. **Build `LoginPage`** posting to `/api/auth/login`, showing one generic error for any failure.

5. **Attach the token in the API client**, in one place, kept in step with the context.

6. **Persist across reloads** with `sessionStorage`, restoring it in the initial state. In
   `docs/auth.md`, compare `sessionStorage`, `localStorage` and an `HttpOnly` cookie in a table,
   and justify the choice.

7. **Protect the routes** with a `RequireAuth` layout route redirecting to `/login` with
   `replace` and `state.from`.

8. **Prove the return works.** Visit `/orders/5001` signed out, sign in, and show landing on
   `/orders/5001` rather than `/orders`.

9. **Handle expiry.** Issue a token with a 30-second TTL, wait for it, act, and show the app
   logging out, redirecting, and explaining why. Screenshot it.

10. **Hide what would fail.** Show the cancel button only for staff. Then prove hiding is not
    security: sign in as a customer, take the token from devtools, and `curl` the endpoint.
    Record the API's 403 in `docs/auth.md` and explain which layer actually enforced it.

## Acceptance

- [ ] `AuthProvider` holds session state; `useAuth` throws a clear error outside it.
- [ ] The context value is memoised, with before-and-after re-render screenshots.
- [ ] The token is attached in the API client only, never at a call site.
- [ ] The session survives a reload, with the storage trade-off table completed.
- [ ] `RequireAuth` redirects with `replace` and `state.from`.
- [ ] Signing in returns the user to the page they originally requested.
- [ ] Expiry logs out, redirects, and explains, screenshotted.
- [ ] The `curl` demonstration shows the API returning 403 with the button hidden.
- [ ] No token or credential is logged to the console.

---

Next: [Testing, Error Boundaries & the Production Build](testing-and-production.md).
