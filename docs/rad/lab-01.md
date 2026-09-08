# Lab 01 — Components, props and state

**Duration:** 120 min · **Objectives:** RAD-K1

## Objectives

After this lab, learners can:

- Scaffold a typed React project and compose components.
- Distinguish props, state and derived state.
- Render lists with stable keys.

## Before you start

- You have read [React, JSX, Components & State](components-and-state.md).
- Node 20+ is installed.

## Steps

1. **Scaffold** with `npm create vite@latest orderdesk-web -- --template react-ts`. Confirm
   `npm run dev` serves it.

2. **Port the fixture** from Frontend Foundations lab 02 into `src/fixtures/orders.ts`, typed
   with the interfaces from that module.

3. **Build four components:** `StatusBadge`, `OrderRow`, `OrdersTable`, `OrderFilters`. Every
   one has a typed props interface. No `any`.

4. **Keep the semantics.** The table keeps its `<caption>`, `<thead>` and `scope="col"` headers
   from Frontend Foundations.

5. **Add filter state** to `OrdersPage` and pass it down. In `docs/state.md`, list every value
   in the page and classify it as prop, state or derived, with one line of justification.

6. **Derive, do not store.** The visible list and the total are computed in render. Show in
   `docs/state.md` the `useState` + `useEffect` version you did *not* write, and say what could
   go wrong with it.

7. **Demonstrate the mutation bug.** Add a row with `orders.push(...)` and `setOrders(orders)`,
   record that nothing renders, then fix it with a spread and record the difference.

8. **Demonstrate the stale closure.** Call `setCount(count + 1)` twice and record that it
   increments once. Fix with the updater form and record it.

9. **Demonstrate index keys.** Give each row a text input, key by index, delete the first row,
   and record the typed text attaching to the wrong row. Switch to `key={order.id}` and show it
   fixed. Screenshot both into `docs/state.md`.

10. **Lift state up.** Make the filters and a result count both read the same value, owned by
    their common ancestor.

## Acceptance

- [ ] The project builds and `npm run dev` serves it with no TypeScript errors.
- [ ] Four components exist, each with a typed props interface; no `any`.
- [ ] The table retains caption, `thead` and scoped headers.
- [ ] `docs/state.md` classifies every value as prop, state or derived.
- [ ] The visible list and total are derived, not stored.
- [ ] The mutation demonstration shows no re-render, then a correct one.
- [ ] The stale-closure demonstration shows one increment, then two.
- [ ] The index-key demonstration is screenshotted before and after.
- [ ] Filter state is lifted to the common ancestor.

---

Next: [Effects, Data Fetching & Custom Hooks](effects-and-data-fetching.md).
