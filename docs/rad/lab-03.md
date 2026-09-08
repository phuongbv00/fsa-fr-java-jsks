# Lab 03 — Routing, layouts and URL state

**Duration:** 120 min

## Objectives

By the end of this lab you will be able to:

- Configure routes inside a shared layout.
- Read and validate route parameters and query strings.
- Handle both kinds of not-found.

## Before you start

- You have read [Routing & Shared Layouts](routing-and-layouts.md).
- Lab 02 is complete.

## Steps

1. **Install `react-router-dom`** and configure a browser router.

2. **Build `AppLayout`** with header, `<nav>` and `<Outlet />`. Use `NavLink` with an active
   class, and confirm in the accessibility tree that it sets `aria-current="page"` on the
   active link by itself.

3. **Add routes:** `/orders`, `/orders/:orderId`, `/products`, a redirect from `/`, and `*` last.

4. **Build `OrderDetailPage`** reading `orderId` with `useParams`, converting it to a number and
   rejecting anything that is not one — without calling a hook after the early return; hand the
   valid id to a child component that calls `useOrder`. Show what `/orders/abc` renders.

5. **Demonstrate the anchor bug.** Link to a detail page with `<a href>`, record the full reload
   and the lost state, then switch to `<Link>` and record the difference.

6. **Move filters into the URL** with `useSearchParams`, so `/orders?status=PLACED` reproduces
   the filtered screen after a reload.

7. **Prove it.** Filter, copy the URL, open it in a new tab, and screenshot the same screen.

8. **Use `replace` for filters** and demonstrate why: change filters five times, then press back
   five times with and without `replace`, and record the difference.

9. **Handle both not-founds.** `/ordrs` renders the not-found page; `/orders/99999` renders an
   order-specific message. Both offer a link out. Screenshot both.

10. **Reset the page on filter change.** Go to page 3, change the filter, and show that you land
    on page 0 rather than an empty page 3.

## Acceptance

- [ ] Routes render inside `AppLayout` via `<Outlet />`; `*` is last.
- [ ] `NavLink` marks the active route with `aria-current="page"`, set by the router.
- [ ] `orderId` is converted and validated; `/orders/abc` is handled; no hook follows an early return.
- [ ] The anchor-versus-Link demonstration is recorded.
- [ ] Filters live in the URL and survive a reload in a new tab, with a screenshot.
- [ ] The back-button behaviour with and without `replace` is recorded.
- [ ] Both not-found kinds are handled and screenshotted, each with a link out.
- [ ] Changing a filter resets the page number.

---

Next: [Forms, Validation & Mutations](forms-and-mutations.md).
