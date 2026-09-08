# Lab 02 — Effects, fetching and a custom hook

**Duration:** 150 min · **Objectives:** RAD-K1

## Objectives

After this lab, learners can:

- Use `useEffect` with a correct dependency array and cleanup.
- Fetch typed data and render all four states.
- Extract a custom hook and cancel stale requests.

## Before you start

- You have read [Effects, Data Fetching & Custom Hooks](effects-and-data-fetching.md).
- Lab 01 is complete.
- Your OrderDesk API is running and allows `http://localhost:5173`.

## Steps

1. **Port the API client** from Frontend Foundations lab 03, including `ApiError`, the status
   check, the 204 case and the `AbortController` timeout.

2. **Replace the fixture** with a real fetch in `OrdersPage`, inside an effect.

3. **Render all four states:** loading, empty, success, error — with `role="status"` and
   `role="alert"` where appropriate.

4. **Demonstrate the infinite loop.** Depend on an object literal, record the Network tab filling
   with requests, then depend on a primitive and record it stopping. Screenshot both into
   `docs/effects.md`.

5. **Demonstrate the missing dependency.** Use the filter inside an effect with `[]`, record that
   changing it does nothing, then add the dependency.

6. **Add the ESLint hooks plugin** with `react-hooks/exhaustive-deps` as an error, and fix
   everything it reports. Record what it found.

7. **Demonstrate the race.** Add an artificial delay to the API for one filter value, switch
   filters quickly, and record the screen showing results that contradict the filter. Fix it with
   `AbortController` and record the fix.

8. **Explain Strict Mode.** Record the two requests in development, explain why, and confirm
   production issues one.

9. **Extract `useOrders`** returning `{ orders, loading, error, reload }`, with cancellation
   inside. `OrdersPage` should now contain no fetch logic.

10. **Extract `useOrder(orderId)`** for a single order, clearing the previous value while
    loading. Demonstrate the flash of stale data without the clear, and its absence with it.

## Acceptance

- [ ] `OrdersPage` fetches real data and renders all four states.
- [ ] `docs/effects.md` shows the infinite-loop Network tab before and after.
- [ ] The missing-dependency demonstration is recorded.
- [ ] `react-hooks/exhaustive-deps` runs as an error and reports nothing.
- [ ] The race demonstration shows contradictory results, then the fix.
- [ ] The Strict Mode double-invocation is explained.
- [ ] `useOrders` and `useOrder` exist; pages contain no fetch logic.
- [ ] The stale-data flash is demonstrated and fixed.
- [ ] Every effect that starts something returns a cleanup.

---

Next: [Routing & Shared Layouts](routing-and-layouts.md).
