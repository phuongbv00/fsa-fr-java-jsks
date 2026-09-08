# Agile & Scrum

> Objectives: FND-K1 · Session 1 · See [Agile, Git & AI-Assisted Development Foundations — Study Guide](index.md).

## 1. Objectives

After this unit, learners can:

- State the Agile values and explain what each one trades away.
- Name the Scrum roles, events and artifacts, and say what each one is accountable for.
- Distinguish a product goal from a sprint goal, and a sprint goal from a list of tasks.
- Write a user story with acceptance criteria a reviewer can check.
- Distinguish acceptance criteria from a Definition of Done.
- Order a backlog and justify why one item comes before another.

## 2. What Agile Is Actually Claiming

Agile is a response to one observation: on software projects, what the customer wants is
discovered while building, not before. Every practice in this unit follows from that.

The four values each state a preference between two good things:

| Prefer | Over | Because |
|---|---|---|
| Individuals and interactions | Processes and tools | A process cannot notice that the requirement was wrong. |
| Working software | Comprehensive documentation | A document is a claim; running software is evidence. |
| Customer collaboration | Contract negotiation | A contract fixes what was wanted in month one. |
| Responding to change | Following a plan | A plan built on month-one knowledge is at its least accurate on day one. |

> **Note.** The sentence that follows the four values in the manifesto is the one people
> skip: *there is value in the items on the right*. Agile does not say documentation is
> worthless. It says that when the two conflict, working software wins.

**Real-world use.** On OrderDesk, the stakeholder described returns in one sentence and
then changed it three times once they saw the first screen. That is not a badly run
project — that is the normal case Agile is built for.

## 3. Scrum in One Pass

Scrum is one way to work in the manner the values describe. It is deliberately small:
three accountabilities, five events, three artifacts.

```text
Product Backlog ──(Sprint Planning)──> Sprint Backlog ──> Daily Scrum (each day)
                                             │
                                             ▼
                                          Increment ──(Sprint Review)──> feedback
                                             │
                                             └──(Sprint Retrospective)──> improvement
```

**Accountabilities**

| Role | Accountable for | Not accountable for |
|---|---|---|
| Product Owner | The value of the product; the order of the backlog | Telling developers how to build it |
| Scrum Master | The team's effectiveness; removing impediments | Assigning work or reporting on people |
| Developers | The increment, its quality, and how the work gets done | Deciding what the business needs most |

**Events**

| Event | Length in a 2-week sprint | Produces |
|---|---|---|
| Sprint | 2 weeks | A usable increment |
| Sprint Planning | up to 4 h | A sprint goal and a sprint backlog |
| Daily Scrum | 15 min | An adjusted plan for the next day |
| Sprint Review | up to 2 h | Feedback on the increment, and backlog changes |
| Sprint Retrospective | up to 1.5 h | One or two improvements the team will actually try |

**Artifacts**, each with a commitment attached:

| Artifact | Commitment |
|---|---|
| Product Backlog | Product Goal |
| Sprint Backlog | Sprint Goal |
| Increment | Definition of Done |

> **Tip.** The commitment is what makes the artifact more than a list. A backlog with no
> product goal is a to-do list; a sprint backlog with no sprint goal is a set of unrelated
> tickets that happen to be in the same fortnight.

### The Daily Scrum is not a status report

```text
# Wrong — a report to the Scrum Master, three people talking to one
"Yesterday I worked on the return screen. Today I'll continue. No blockers."

# Right — developers replanning their own day, out loud, to each other
"The return screen needs the refund rule, and I still don't know what happens
 to a partially shipped order. If nobody has an answer by 11:00 I'll take the
 courier-timeout item instead and we can ask the PO at the review."
```

The first version could be an email. The second changes what happens today.

## 4. Product Goal, Sprint Goal, and the Difference

A **product goal** is the longer-term objective the backlog exists to reach. A **sprint
goal** is the single reason this sprint is worth running — one sentence, agreed at
planning, and it is what the team protects when things go wrong.

```text
Product goal:  Staff can handle every order case without leaving OrderDesk.

Sprint goal:   Staff can cancel an order and see the stock released.

Not a sprint goal:  Finish ORD-14, ORD-15, ORD-19 and start ORD-22.
```

The test: if two of the five items turn out to be much harder than expected, the sprint
goal tells you what to drop. A list of ticket numbers does not.

## 5. User Stories and Acceptance Criteria

The story format carries three pieces of information — who benefits, what they can do,
and why it matters:

```text
As a warehouse operator
I want to see which units of an order are already reserved
So that I don't pick stock that another order has claimed
```

The "so that" is the part people drop, and it is the part that lets a developer make a
sensible decision when the story turns out to be ambiguous.

**Acceptance criteria** are the conditions a reviewer checks. They are written before the
work, they are specific to this story, and they are observable.

```text
# Wrong — not checkable; two people will disagree about whether it is met
- Reservation works properly
- Good performance
- Handles errors

# Right — a reviewer can sit down and confirm each of these
- An order line showing reserved stock displays the reserving order's number.
- Attempting to reserve a unit already reserved by another order is refused,
  and the message names the other order.
- An order with no reserved units shows "No stock reserved" rather than an
  empty table.
- Reserving stock for a cancelled order is refused.
```

The fourth criterion is the one that matters most: it came from asking "what should
*not* happen?" Most missing acceptance criteria are found by that question.

> **Real-world use.** On OrderDesk, "partial shipment" was written as one line by the
> stakeholder. Turning it into acceptance criteria surfaced three questions nobody had
> answered — when is a partly-shipped order "complete", can it still be cancelled, and
> what does the customer's invoice say. Three questions found in ten minutes, rather than
> in production.

## 6. Definition of Done

The Definition of Done applies to **every** item, and it does not change between stories.
Acceptance criteria apply to **one** story.

| | Acceptance criteria | Definition of Done |
|---|---|---|
| Scope | This story only | Every item in the sprint |
| Written by | Product Owner with the team, per item | The team, once, and revised at retrospectives |
| Example | "Cancelling releases the reserved stock" | "Reviewed by a peer and merged to `main`" |

A workable starting Definition of Done for OrderDesk:

```text
- The change is on a feature branch and merged through a reviewed pull request.
- The acceptance criteria of the story are each demonstrated.
- No known defect is left open against the story.
- Anything a future reader would need to know is written down.
- Any AI-assisted work is documented and verified.
```

> **Note.** A Definition of Done you cannot meet is worse than a short one. Write what the
> team will actually do every time, then tighten it at a retrospective.

## 7. Ordering the Backlog and Estimating

The backlog is **ordered**, not prioritised into buckets. Exactly one item is next. Four
questions decide the order:

1. What does this unlock? An item three others depend on rises.
2. What do we not yet understand? Doing an uncertain item early buys information.
3. What is the cost of being wrong later? Rules that touch money move up.
4. What is the smallest thing that gets feedback?

Estimates are **relative**, not hours. The team compares an item with one they have
already done and asks "bigger, smaller, or about the same". Relative estimates work
because humans compare well and predict absolutely badly.

```text
# Wrong — a number invented alone, then defended
"Cancellation is 6 hours."

# Right — a comparison, and the disagreement is the useful part
"Cancellation is about the same as the address-change story we did — call it a 3."
"I'd say 8: cancellation has to release stock, and we've never touched that."
   -> the gap is the discussion. Someone knows something the other doesn't.
```

When two estimates are far apart, the estimate is not the point — the hidden assumption
is. Find it before you agree a number.

## 8. Common Problems

### The sprint goal is a list of ticket numbers

Nothing can be dropped when work runs late, because there is no statement of what the
sprint was for. Write one sentence describing the outcome, and check that every item in
the sprint backlog serves it.

### Acceptance criteria that repeat the story

"As a staff member I want to cancel an order" followed by "the staff member can cancel
the order" adds nothing. Criteria should say what happens at the edges: what is refused,
what is shown when there is no data, what happens when the external system is down.

### The Definition of Done is aspirational

The team writes an ambitious list at the start and quietly ignores half of it by week
three. An ignored standard trains everyone that standards are optional. Cut it to what
you do every time, and add to it at a retrospective when the team is ready.

### Estimates get treated as commitments

Someone records "3 points" as "3 days" and holds the team to it. An estimate is an input
to a forecast, not a promise. If estimates are being used as deadlines, the team will
inflate them and they stop carrying any information.

### The retrospective produces a list nobody does

Twelve improvements, none owned, none revisited. Leave with one or two changes, each with
a name against it, and start the next retrospective by checking them.

## 9. Practical Guidelines

- Write the "so that" clause. If you cannot, the story may not be worth doing.
- Write at least one acceptance criterion describing what should be refused.
- Ask "how would a reviewer check this?" of every criterion, and rewrite the ones with no
  answer.
- Keep the Definition of Done to what the team already does every time.
- Order the backlog to exactly one next item; a tie means the ordering conversation is
  not finished.
- Estimate by comparison, and treat a large disagreement as a question, not an average.
- At the retrospective, leave with fewer improvements than you can count on one hand.

## 10. Knowledge Check

1. The Agile values each prefer one thing over another. What does the manifesto say about
   the items on the right, and why does that sentence matter?
2. A team's sprint goal is "complete ORD-14, ORD-15 and ORD-19". Two of the three turn out
   to be twice the expected size. What can the team not do that a proper sprint goal would
   have made possible?
3. Give one acceptance criterion for "cancel an order" that describes something that
   should be refused rather than something that should work.
4. A trainee writes "the code is reviewed" as an acceptance criterion on a story. What is
   wrong with that placement, and where does it belong?
5. Two developers estimate the same item at 3 and 13. What should the team do, and why is
   averaging the worst option?
6. What is the Product Owner accountable for that the Developers are not, and what are the
   Developers accountable for that the Product Owner is not?
7. How would you tell, watching one, whether a Daily Scrum is a replanning event or a
   status report?

## 11. Further Reading

- [The Scrum Guide](https://scrumguides.org/scrum-guide.html) — the whole framework, and
  short enough to read in one sitting.
- [Manifesto for Agile Software Development](https://agilemanifesto.org/) — the four
  values and the twelve principles behind them.
- [Principles behind the Agile Manifesto](https://agilemanifesto.org/principles.html) —
  where the practices in this unit come from.

Next: [Git Fundamentals](git-fundamentals.md), and the lab for this unit is
[Lab 01 — Refine the OrderDesk returns backlog](lab-01.md).
