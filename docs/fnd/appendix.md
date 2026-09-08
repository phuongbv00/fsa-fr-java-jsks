# Agile, Git & AI-Assisted Development Foundations — Appendix

## A. Full Syllabus Map

- [ ] Agile & Scrum → [01](agile-and-scrum.md#agile-scrum)
- [ ] Git & Collaborative Workflow → [03](pull-requests-and-conflicts.md#pull-requests-collaborative-workflow)
- [ ] AI-Assisted Development → [04](ai-assisted-development.md#ai-assisted-development)
- [ ] Final Assessments

## B. Key topics

Two things the derived map cannot say on its own:

- **Git & Collaborative Workflow spans two notes.** The map links the outline item to
  [03](pull-requests-and-conflicts.md), which covers remotes, pull requests, review and
  conflicts. The local half — states, staging, commits, history, branches, merge, ignore
  rules and recovery — is [Git Fundamentals](git-fundamentals.md). Revise both.
- **Final Assessments has no note by design.** It is the quizzes and the two final exams,
  which are assessment artifacts rather than teaching material. Your trainer supplies them.

Revise in this order. Each is something the module tests and the next module assumes.

- **Acceptance criteria that describe a refusal.** The commonest gap in trainee work is
  criteria that only cover the happy path — section 5 of
  [Agile & Scrum](agile-and-scrum.md).
- **Acceptance criteria versus Definition of Done.** One story against every story;
  section 6 of [Agile & Scrum](agile-and-scrum.md).
- **The four file states and the commands between them.** Section 2 of
  [Git Fundamentals](git-fundamentals.md). Everything else in Git is built on this.
- **Focused commits and why the staging area exists.** Section 3 of
  [Git Fundamentals](git-fundamentals.md).
- **Fast-forward versus three-way merge.** What decides which one happens — section 5 of
  [Git Fundamentals](git-fundamentals.md).
- **Recovering with `git reflog` rather than panicking.** Section 7 of
  [Git Fundamentals](git-fundamentals.md).
- **Resolving a conflict and then verifying it.** The markers being gone is not
  verification — section 6 of
  [Pull Requests & Collaborative Workflow](pull-requests-and-conflicts.md).
- **`--force-with-lease` over `--force`, and why.** Section 7 of
  [Pull Requests & Collaborative Workflow](pull-requests-and-conflicts.md).
- **The AI failure modes and the symptom of each.** Section 3 of
  [AI-Assisted Development](ai-assisted-development.md).
- **Deciding the check before generating.** Section 6 of
  [AI-Assisted Development](ai-assisted-development.md). This is the habit the
  final practice exam looks for.

## C. Reference List

Primary sources only. Where a claim in a note disagrees with one of these, the source wins.

**Agile and Scrum**

- [The Scrum Guide](https://scrumguides.org/scrum-guide.html)
- [Manifesto for Agile Software Development](https://agilemanifesto.org/)
- [Principles behind the Agile Manifesto](https://agilemanifesto.org/principles.html)

**Git and collaboration**

- [Pro Git](https://git-scm.com/book/en/v2) — chapters 2, 3 and 5 cover this module.
- [Git reference documentation](https://git-scm.com/docs)
- [About pull requests](https://docs.github.com/en/pull-requests)

**AI-assisted development**

- The documentation for the approved AI coding assistant, including what it sends as
  context and what your licence permits.
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [MDN Web Docs](https://developer.mozilla.org/)

## D. Glossary

Terms the module uses and does not stop to define. The handbook glossary covers the basics;
these are the ones that catch people out.

- **Accountability** — in Scrum, what a role answers for. Not the same as a job title, and
  one person can hold more than one.
- **Impediment** — anything slowing the team that the team cannot remove alone.
- **Increment** — the sum of all finished work, in a releasable state. Finished means it
  meets the Definition of Done.
- **Relative estimate** — a size expressed by comparison with a known item, not in hours.
- **Refinement** — the ongoing work of adding detail and order to the backlog. Not an event
  with a fixed length.
- **HEAD** — where you are right now: normally the tip of the current branch.
- **Detached HEAD** — `HEAD` pointing at a commit rather than a branch, so new commits
  belong to no branch.
- **Index** — the staging area. Three names for one thing: index, staging area, cache —
  which is why `git rm --cached` ("remove from the cache") stops tracking a file without
  deleting it. Unstaging a change is `git restore --staged`.
- **Tracking branch** — a local branch that knows which remote branch it corresponds to,
  which is what `git push -u` sets up.
- **Fast-forward** — a merge that only moves a branch label, because the history had not
  diverged.
- **Upstream** — the remote branch your local branch tracks.
- **Protected branch** — a branch the hosting platform refuses direct pushes to, so changes
  arrive only through review.
- **Context window** — how much text the assistant can consider at once. Exceeding it is
  why long sessions drift.
- **Knowledge cut-off** — the point after which the assistant knows nothing, and the reason
  its advice about library versions may be stale.
- **Hallucination** — fluent, confident output describing something that does not exist.
- **Grounding** — supplying real code, documentation or data so an answer is anchored to
  something checkable.
