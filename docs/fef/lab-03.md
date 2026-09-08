# Lab 03 — Typed access to the real API

**Duration:** 180 min

## Objectives

By the end of this lab you will be able to:

- Model an API contract with TypeScript types.
- Call a real API with `fetch`, handling status codes and timeouts.
- Represent loading, empty, success and error in the type system.
- Read and fix TypeScript errors rather than silencing them.

## Before you start

- You have read [Async JavaScript & Strict TypeScript](async-and-typescript.md).
- Lab 02 is complete.
- Your OrderDesk API from Spring Boot API Development is running on port 8080.

## Steps

1. **Turn strictness on.** `strict`, `noUncheckedIndexedAccess`, `noUnusedLocals`,
   `noUnusedParameters`. Convert lab 02's modules to `.ts` and fix every error. Record the
   count of errors it found in `docs/types.md`.

2. **Model the contract** in `api/types.ts`: `Order`, `OrderLine`, `Page<T>`, `ApiErrorBody`,
   and `OrderStatus` as a union of literals, matching what your API actually returns.

3. **Prove the union works.** Write `label(status)` as an exhaustive `switch` with no `default`.
   Add a status to the union, screenshot the compile error, and remove it again.

4. **Write the client** with `ApiError`, a status check, error-body reading, a 10-second
   `AbortController` timeout, and correct handling of 204.

5. **Prove `fetch` does not reject.** Call an endpoint that 404s without checking `response.ok`,
   record what happens, then add the check and record the difference.

6. **Log in** against `/api/auth/login`, store the token, and attach it as a Bearer header on
   every request.

7. **Model the view state** as a discriminated union with all four cases, and drive `render`
   from it with an exhaustive `switch`.

8. **Demonstrate every state against the real API:** loading with a throttled connection; empty
   with a filter matching nothing; success; and error four ways — 401 with no token, 403 with a
   customer token on a staff action, a timeout, and a stopped API. Screenshot all seven into
   `docs/states.md`.

9. **Map statuses to messages a user can act on.** No raw status codes or stack traces reach the
   screen. Record the mapping.

10. **Show CORS, then fix it.** Serve the page from a port your API does not allow, record the
    `TypeError: Failed to fetch` and the console message, then add the origin to the API's CORS
    configuration and show it working. Explain in `docs/states.md` why the fix was server-side.

11. **Parallelise.** Load orders and products together with `Promise.all`, and record the
    waterfall in the Network tab before and after.

## Acceptance

- [ ] `strict` and the three extra checks are on, and the initial error count is recorded.
- [ ] The contract is modelled with interfaces and a literal union for status.
- [ ] The exhaustive `switch` compile error is demonstrated.
- [ ] Every `fetch` checks `response.ok`; 204 does not call `json()`.
- [ ] A timeout via `AbortController` is implemented and demonstrated.
- [ ] The token is attached to every authenticated request.
- [ ] View state is a discriminated union with four cases and an exhaustive `render`.
- [ ] `docs/states.md` contains seven screenshots covering every state and four error kinds.
- [ ] No status code or stack trace appears in the interface.
- [ ] The CORS failure and its server-side fix are recorded.
- [ ] Network waterfalls before and after `Promise.all` are recorded.
- [ ] No `any` and no `!` non-null assertion appears in the solution.

---

Next: [Frontend Foundations — Appendix](appendix.md).
