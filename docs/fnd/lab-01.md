# Lab 01 — Refine the OrderDesk returns backlog

**Duration:** 75 min

This is guided practice, not an assessed assignment. Work in your team, and expect the
trainer to interrupt with a stakeholder change part way through.

## Objectives

By the end of this lab you will be able to:

- Turn a stakeholder's raw request into user stories with a "so that" clause.
- Write acceptance criteria a reviewer could check, including what must be refused.
- Estimate by comparison and use a disagreement to surface a hidden assumption.
- Agree a Definition of Done the team will actually meet.
- Order a backlog to a single next item and justify the order.

## Before you start

- You have read [Agile & Scrum](agile-and-scrum.md).
- You know the OrderDesk domain from section 2 of
  [Agile, Git & AI-Assisted Development Foundations — Study Guide](index.md).
- You have the **stakeholder brief** — one page of raw notes from a meeting about returns
  and refunds, deliberately vague and partly contradictory. Get it from
  [`labs/fnd/lab-01-stakeholder-brief`](https://github.com/phuongbv00/fsa-fr-java-jsks/tree/main/labs/fnd/lab-01-stakeholder-brief).
- Somewhere to write the backlog that everyone can see: a board, a shared document or a
  wall of sticky notes.

## Steps

1. Read the stakeholder brief as a team and, without writing any stories yet, list every
   **question** the brief does not answer. Aim for at least eight. You should now have a
   visible list of unknowns.

2. Write a one-sentence **product goal** for OrderDesk returns. Check it against the brief:
   if a sentence in the brief does not serve your goal, either the goal is too narrow or
   that sentence is out of scope. Say which.

3. Split the brief into **user stories** in the `As a … I want … So that …` form. Aim for
   six to eight. Every story must name a real role — warehouse operator, refunds clerk,
   team lead — not "user". Write them where the whole team can see them.

4. Pick the **two stories you understand least** and write acceptance criteria for them.
   Each story needs at least four criteria, and at least one must describe something that
   should be **refused**. Read each criterion aloud and ask "how would a reviewer check
   this?" — rewrite any that has no answer.

5. Trade with another team. Review their two stories against one question only: *could I
   check every one of these criteria without asking them anything?* Write your answer next
   to each criterion — checkable, or not, and why. Take your own back and fix what they
   flagged.

6. **Estimate** all your stories by comparison. Pick the one you understand best, call it a
   3, and size the rest against it. Where two people are more than one size apart, stop and
   find the assumption they disagree about — write that assumption down next to the story.
   You should finish with at least two written-down assumptions.

7. Agree a **Definition of Done** for the team. Five or six lines, and the test for each
   line is: *will we do this every single time?* Delete anything that fails that test.
   Compare it with the example in section 6 of [Agile & Scrum](agile-and-scrum.md)
   and say why yours differs.

8. **Order** the backlog. Put every story in a single ordered column and be ready to answer,
   for the top three, why each comes before the next. Use the four questions from section 7
   of the note. There must be exactly one item at the top.

9. The trainer now gives you a **stakeholder change**. Apply it: adjust the affected
   stories and criteria, re-estimate anything whose size changed, and re-order. Note which
   items moved and why — that record is what you discuss in the review.

## Acceptance

- [ ] At least eight open questions from the brief are written down.
- [ ] A one-sentence product goal exists, and every story serves it.
- [ ] Six or more stories are written with a role and a "so that" clause.
- [ ] Two stories have four or more acceptance criteria each.
- [ ] At least one criterion on each of those describes something that is refused.
- [ ] Another team confirmed every criterion is checkable without asking you.
- [ ] Every story carries a relative estimate.
- [ ] At least two hidden assumptions surfaced by estimate disagreements are written down.
- [ ] A Definition of Done of five or six lines exists, and the team agrees it will meet
      every line every time.
- [ ] The backlog is a single ordered list with exactly one item at the top, and you can
      justify the top three.
- [ ] The stakeholder change has been applied, and the items that moved are recorded.
