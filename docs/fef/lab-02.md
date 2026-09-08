# Lab 02 — Render from data and handle events

**Duration:** 150 min

## Objectives

By the end of this lab you will be able to:

- Organise code into ES modules.
- Render a list from an array and re-render on change.
- Use event delegation for controls that come and go.
- Avoid injecting untrusted data as markup.

## Before you start

- You have read [Modern JavaScript, the DOM & Events](javascript-dom-and-events.md).
- Lab 01 is complete.

## Steps

1. **Split into modules:** `api/orders.js` (a fixture array for now), `ui/table.js`,
   `ui/orders-screen.js`, `main.js`. No global variables.

2. **Write a fixture** of at least 15 orders with varied statuses, dates and totals. One
   customer name must contain `<img src=x onerror="alert(1)">`.

3. **Render the table** with `createElement` and `textContent`, then `replaceChildren`.

4. **Prove the injection.** Temporarily render that name with `innerHTML`, screenshot the result,
   then restore `textContent` and screenshot the name displayed literally. Both go in
   `docs/dom.md` with an explanation.

5. **Implement filtering** with `filter`, sorting with a copied `sort`, and a total with
   `reduce`. No index loops.

6. **Show why the copy matters.** Sort without copying, then filter, and record the row order
   changing unexpectedly. Fix it with a spread and record the difference.

7. **Wire the filter form** with `submit` and `preventDefault`, reading values with `FormData`.

8. **Add a cancel button per row,** enabled only for `PLACED` orders, handled by **one**
   delegated listener on the tbody.

9. **Prove delegation matters.** Attach listeners per button instead, re-render, and record that
   they no longer work. Restore delegation and show it surviving a re-render.

10. **Implement the four states** in one `render` function driven by a single state object:
    loading, empty, success, error. Add a control that forces each one so all four can be
    demonstrated, and screenshot each into `docs/dom.md`.

## Acceptance

- [ ] Code is split into at least four modules with no globals.
- [ ] Rows are built with `createElement` and `textContent`.
- [ ] `docs/dom.md` shows the injection with `innerHTML` and its absence with `textContent`.
- [ ] Filtering, sorting and totals use array methods; sorting copies first.
- [ ] The mutation demonstration is recorded, before and after.
- [ ] The form uses `preventDefault` and `FormData`.
- [ ] Exactly one delegated listener handles all cancel buttons.
- [ ] The per-button demonstration shows listeners lost after a re-render.
- [ ] All four states render from one state object, each screenshotted.

---

Next: [Async JavaScript & Strict TypeScript](async-and-typescript.md).
