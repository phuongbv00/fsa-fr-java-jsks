# Lab 01 — Build the orders screen, semantic and responsive

**Duration:** 150 min · **Objectives:** FEF-K1

## Objectives

After this lab, learners can:

- Structure a page with landmarks and a correct heading outline.
- Build a labelled, keyboard-operable filter form.
- Lay out a page with Grid and a toolbar with Flexbox, responsively.

## Before you start

- You have read [Semantic HTML & Responsive Layout](semantic-html-and-layout.md).
- Node 20+ is installed and `npm create vite@latest` works.

## Steps

1. **Scaffold** a `vanilla-ts` Vite project and confirm `npm run dev` serves it.

2. **Build the page skeleton** with `<header>`, `<nav>`, `<main>` and `<footer>`, one `<h1>`,
   and a heading outline that skips no levels.

3. **Build the filter form** with a status select, a date range and a checkbox in a `fieldset`
   with a `legend`. Every control has a `<label for>`.

4. **Build the orders table** with `<caption>`, `<thead>`, `scope="col"` headers and an empty
   `<tbody>`. Wrap it in an `overflow-x: auto` container.

5. **Set `box-sizing: border-box`** globally as the first rule, and add the viewport meta tag.

6. **Lay out the page with Grid** using `grid-template-areas`, and the toolbar with Flexbox
   using `gap`.

7. **Make it responsive, mobile first.** Single column below 48rem; sidebar and main above it;
   wider sidebar above 75rem. Breakpoints in `rem`.

8. **Prove the viewport tag matters.** Remove it, screenshot the phone rendering, restore it,
   screenshot again. Put both in `docs/layout.md` with one sentence explaining the difference.

9. **Audit the accessibility tree.** Open devtools' Accessibility pane and screenshot it,
   showing the landmarks and the heading outline. Any heading not appearing there is a bug.

10. **Test the keyboard.** Tab through the whole page without a mouse. Every control must be
    reachable, in visual order, with a visible focus ring. Record the tab order in
    `docs/layout.md` and fix anything unreachable.

11. **Run Lighthouse** on the Accessibility category and record the score with any failures and
    what you changed.

## Acceptance

- [ ] The page uses `<header>`, `<nav>`, `<main>`, `<footer>` and one `<h1>`.
- [ ] The heading outline skips no levels.
- [ ] Every form control has an associated `<label for>`; no placeholder is used as a label.
- [ ] The table has a caption and `scope="col"` headers, and scrolls inside its container.
- [ ] `box-sizing: border-box` is set globally; the viewport meta tag is present.
- [ ] The page layout uses Grid areas; the toolbar uses Flexbox with `gap`.
- [ ] Three mobile-first breakpoints in `rem`, and the layout works at all three.
- [ ] `docs/layout.md` shows the viewport-tag comparison and the accessibility-tree screenshot.
- [ ] Every control is keyboard-reachable in visual order with a visible focus ring.
- [ ] A Lighthouse accessibility score is recorded with any fixes made.

---

Next: [Modern JavaScript, the DOM & Events](javascript-dom-and-events.md).
