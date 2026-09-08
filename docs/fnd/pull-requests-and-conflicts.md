# Pull Requests & Collaborative Workflow

> Objectives: FND-K2 · Session 3 · See [Agile, Git & AI-Assisted Development Foundations — Study Guide](index.md).

## 1. Objectives

After this unit, learners can:

- Explain what a remote is and how a local branch tracks one.
- Push a branch and open a pull request that a reviewer can act on.
- Review a peer's pull request with comments that are specific and actionable.
- Revise a pull request in response to review and explain what changed.
- Resolve a merge conflict correctly, and verify the resolution rather than assuming it.
- Describe why protected branches and traceable changes exist, as policy they will work
  under.

Unit 2 was you and your repository. This unit is you and everyone else.

## 2. Remotes

A **remote** is another copy of the repository, usually the shared one on the hosting
platform. `origin` is the conventional name for the one you cloned from.

```bash
git remote -v
```

```text
origin  https://git.example.com/orderdesk.git (fetch)
origin  https://git.example.com/orderdesk.git (push)
```

Your local `main` and the shared `main` are different branches that happen to share a
name. Git tracks the last known position of the remote one as `origin/main`.

```bash
git fetch                 # update origin/* — changes nothing you are working on
git pull                  # fetch, then merge into the current branch
git push -u origin feature/cancellation-window   # publish, and set up tracking
```

> **Note.** `git fetch` is always safe: it updates your knowledge of the remote and touches
> nothing else. When you are unsure of the state of the world, fetch and then look.

`origin/main` is a **cached** position. It only moves when you fetch. If a teammate pushed
five minutes ago and you have not fetched, your Git still believes the old position — and
that is behind most confusing messages in this unit.

## 3. The Collaborative Loop

```text
  main ─────────────────────────────────────────> (protected: no direct pushes)
    │                                        ▲
    │ switch -c                              │ merge, after review
    ▼                                        │
  feature/cancellation-window ──> commits ──> push ──> pull request ──> review
                                                            ▲             │
                                                            └── revise ───┘
```

Every change reaches `main` the same way, including small ones:

```bash
git switch main
git pull                                        # start from current main
git switch -c feature/cancellation-window
# ... work, in focused commits ...
git push -u origin feature/cancellation-window
```

Then open the pull request on the platform.

## 4. Writing a Pull Request

A pull request is a request for someone's attention. What you write decides whether that
attention is spent understanding the change or reconstructing it.

```text
# Wrong — the reviewer has to read the whole diff to learn anything
Title: fixes
Description: (empty)
```

```text
# Right — the reviewer knows the goal, the approach and where to look hardest
Title: Refuse cancellation once the order has shipped

## What
Cancellation is now refused after dispatch, and the message names the
shipment that blocked it.

## Why
ORD-31. Staff could cancel an order the courier already had, which left
stock released against goods that were physically gone.

## How to verify
1. Open an order with a dispatched shipment.
2. Press Cancel — it is refused, and the message names the shipment.
3. Open an order not yet dispatched — cancellation still works.

## Notes for the reviewer
The partial-shipment case is the one I am least sure about: I treat an order
as "shipped" if *any* shipment has left. Say if that should be *all*.
```

Keep pull requests small. A reviewer reading 60 lines finds real problems; the same
reviewer on 900 lines approves it. If a change cannot be small, say in the description
which part deserves the attention.

## 5. Reviewing Someone Else's Work

You are reviewing the change, not the person. Three habits carry most of the value.

**Be specific.** Point at a line and say what would go wrong.

```text
# Wrong — the author cannot act on this
"This looks confusing."

# Right — names the case, so the author can check it
"If an order has two shipments and only one has dispatched, this treats
 the whole order as shipped. Is that intended? ORD-31 doesn't say."
```

**Separate what blocks from what does not.** Say which is which, so the author knows what
must change:

```text
Blocking:    the partial-shipment case above
Suggestion:  this could be a named constant, but I don't mind
Question:    is the message shown to staff or logged?
Praise:      thanks for the refusal test, that's the case I'd have missed
```

**Ask rather than assert** when you are not sure. The author usually knows something you
do not, and a question gets that written down where the next reader can find it.

### Responding to review

Reply to every comment, even if only to say what you did. Push the revision as new commits
so the reviewer can see what changed rather than re-reading everything.

```bash
git add src/order/cancellation.js
git commit -m "Treat an order as shipped only when every shipment has dispatched"
git push
```

Disagreeing is fine. Say why, and if it stays unresolved, take it to the whole team rather
than letting the pull request stall for two days.

## 6. Merge Conflicts

A conflict is not an error. It is Git saying: two branches changed the same lines, and a
human has to decide which version is correct.

```bash
git switch feature/cancellation-window
git fetch
git merge origin/main
```

```text
Auto-merging src/order/cancellation.js
CONFLICT (content): Merge conflict in src/order/cancellation.js
Automatic merge failed; fix conflicts and then commit the result.
```

Git writes both versions into the file with markers:

```text
<<<<<<< HEAD
  if (order.hasDispatchedShipment) {
=======
  if (order.shipments.every(s => s.dispatched)) {
>>>>>>> origin/main
```

- Between `<<<<<<< HEAD` and `=======` is **your** branch's version.
- Between `=======` and `>>>>>>>` is the **incoming** version.

Resolving means editing the file until it is correct and deleting all three markers.

```text
# Wrong — keeping one side because it is on top, markers left behind
<<<<<<< HEAD
  if (order.hasDispatchedShipment) {
```

```text
# Right — a deliberate choice, markers gone, and it says what it means
  // ORD-31: every shipment must have dispatched, not just one
  if (order.shipments.every(s => s.dispatched)) {
```

Then finish the merge:

```bash
git add src/order/cancellation.js
git status                # confirms nothing else is still conflicted
git commit                # Git pre-fills the merge message
```

To abandon a merge and return to where you were:

```bash
git merge --abort
```

> **Tip.** After resolving, **run the thing**. A resolution that compiles can still be
> wrong — you may have kept both halves of two incompatible changes. The conflict markers
> being gone is not verification.

Conflicts are cheaper when they are small, which is an argument for pulling `main` into
your branch often rather than once at the end.

## 7. Force-Pushing

If you rewrite history on your branch — an `--amend`, an interactive rebase — the remote
branch no longer matches, and a normal push is refused.

```bash
# Wrong — overwrites the remote branch even if a teammate pushed to it,
# and their commits are gone with no warning
git push --force
```

```bash
# Right — refuses if the remote moved since you last fetched
git push --force-with-lease
```

`--force-with-lease` checks that the remote is where you last saw it. If someone else
pushed, it stops and tells you, instead of destroying their work.

Never force-push a shared branch such as `main`. On your own feature branch, during
review, it is normal.

## 8. Protected Branches and Traceability — Awareness Only

You will not administer these, but you will work under them from your first project.

**Protected branches.** `main` is configured so nobody can push to it directly. Changes
arrive only through a pull request, and the platform can require approvals, passing checks,
or a resolved conversation before merging is allowed. When your push to `main` is rejected,
this is why — it is the rule working, not a fault.

**Traceability.** Organisations require that any change in production can be traced back to
why it was made. That is what the chain of ticket → branch name → commit message → pull
request → approval is for. Practically, it means: put the ticket id in the branch name and
the pull request, and never merge your own unreviewed work.

> **Real-world use.** On a client audit, the question is not "is the code good". It is
> "show me who approved this change and what it was for". A repository where every change
> went through a reviewed pull request answers that in a minute.

## 9. Common Problems

### `Your branch and 'origin/main' have diverged`

You have local commits and the remote has different ones. `git pull` merges the two; if
you would rather your commits sit on top of theirs, `git pull --rebase`. Do not force-push
to fix this.

### `Updates were rejected because the remote contains work that you do not have locally`

Someone pushed after you last fetched. Pull first, resolve anything that conflicts, then
push. This message is Git protecting their work.

### `error: Your local changes to the following files would be overwritten by merge`

You have uncommitted changes in a file the merge needs to touch. Commit them, or
`git stash` them, then merge and `git stash pop`.

### The conflict markers are in the committed file

Someone committed without deleting `<<<<<<<`. Search the repository for `<<<<<<<` before
committing a resolution — most editors will also flag it.

### The pull request shows far more files than you changed

Your branch is based on an old `main`. Merge current `main` into your branch and push; the
pull request will narrow to your actual change.

### The merge is resolved but the behaviour is wrong

You kept both sides of two incompatible changes. Re-read the resolved section as a whole,
and run the change — see the tip in section 6.

## 10. Review Checklist

Before you request review:

- [ ] The branch is named for the work, and carries the ticket id.
- [ ] The pull request says what, why, and how to verify.
- [ ] Current `main` is merged in and the conflicts are resolved and tested.
- [ ] The diff contains only this change — no stray files, no debug output.

When you review someone else's:

- [ ] Every comment names a line and a consequence.
- [ ] Blocking comments are marked as blocking.
- [ ] You said what you would have missed, not only what is wrong.
- [ ] You checked the edge cases the description says are uncertain.

## 11. Knowledge Check

1. What is `origin/main`, and why can it be wrong about where the shared `main` actually is?
2. What does `git fetch` change, and why is it safe to run at any time?
3. A reviewer writes "this looks confusing" on a line. Rewrite it as a comment the author
   can act on, and say what makes the new version better.
4. In a conflict, which side is between `<<<<<<< HEAD` and `=======`? Which is the other?
5. You resolved a conflict and the file compiles. Why is that not enough, and what would
   you do next?
6. What does `--force-with-lease` check that `--force` does not, and whose work does that
   protect?
7. Your push to `main` is rejected by the platform. Give the likely reason and the correct
   next step.
8. A change is in production and an auditor asks why it was made. Name the chain of
   artifacts that answers them.

## 12. Further Reading

- [Pro Git, chapter 5 — Distributed Git](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project)
- [Pro Git — Basic Merge Conflicts](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)
- [git push](https://git-scm.com/docs/git-push) — read the `--force-with-lease` section.
- [About pull requests](https://docs.github.com/en/pull-requests) — the platform's own
  model; the words differ elsewhere but the mechanics do not.

Next: [AI-Assisted Development](ai-assisted-development.md), and the lab for this
unit is [Lab 03 — Pull requests, review and a rehearsed conflict](lab-03.md).
