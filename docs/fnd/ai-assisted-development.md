# AI-Assisted Development

> Objectives: FND-K3 · Session 4 · See [Agile, Git & AI-Assisted Development Foundations — Study Guide](index.md).

## 1. Objectives

After this unit, learners can:

- Name the failure modes an AI coding assistant exhibits and recognise each one in output.
- Explain what the assistant can and cannot see, and supply the context it is missing.
- Use prompt patterns for explaining unfamiliar code and for debugging a real failure.
- Verify a suggestion against a test, observed behaviour or a primary source rather than
  against the assistant's confidence.
- Follow a spec → test → generate → review loop on a bounded change.
- Document accepted and rejected suggestions with the evidence that decided each one.

The examples in this unit are short and deliberately language-light. Nothing here depends
on knowing Java — you start that in the next module.

## 2. What You Are Actually Working With

An AI coding assistant predicts plausible text. It is very good at that, and being
plausible is not the same as being correct. Everything in this unit follows from the gap
between those two.

Three consequences worth holding on to:

- **Fluency is not a signal.** The assistant's tone is identical whether it is right or
  wrong. Confidence carries no information about correctness, so you cannot use it.
- **It has a knowledge cut-off.** It was trained at a point in time. Library APIs, defaults
  and best practice have moved since.
- **It cannot run anything.** Unless a tool is explicitly wired up, it has not executed the
  code it just wrote and does not know whether it works.

> **Note.** This is not an argument against using it. Used well it is a large speed-up. The
> point of this unit is that *you* remain accountable for the output — and in this
> programme, work you cannot explain earns no credit.

## 3. The Failure Modes

Each of these has a symptom you can learn to spot.

| Failure mode | What it looks like | How you catch it |
|---|---|---|
| Hallucinated API | A method or option that reads perfectly and does not exist | Look it up in the official docs |
| Outdated advice | A pattern deprecated two versions ago | Check the version you are actually on |
| Plausible-but-wrong logic | Compiles, runs, wrong at an edge | Test the edge case, not the happy path |
| Insecure suggestion | String-built queries, secrets in code, disabled checks | Ask what an attacker controls |
| Confident fabrication | An invented citation, benchmark or quotation | Follow the link; if there is none, that is the answer |
| Context drift | A later answer contradicts the constraint you set earlier | Restate the constraint; check against your own code |
| Over-scoping | You asked for one fix and got a rewritten module | Read the diff before accepting anything |

### Hallucinated API

```javascript
// The assistant offered this for "cancel every pending order".
// It reads perfectly. `cancelAllPending` does not exist in the OrderDesk code.
orderService.cancelAllPending({ before: cutoffDate });
```

The tell is that it is *exactly* what you wished existed. When a suggested call is
suspiciously convenient, search the codebase for it before anything else.

### Plausible-but-wrong logic

```javascript
// Asked: "refuse cancellation once the order has shipped."
// This is right for a single shipment and wrong for OrderDesk's partial shipments:
// an order with one of two boxes dispatched is not fully shipped, and this refuses it.
if (order.shipments.length > 0) {
  return refuse("Order has already shipped");
}
```

Nothing about this looks wrong. It was caught by someone who asked what happens when an
order has two shipments and one has dispatched — the domain question, not a code question.

### Insecure suggestion

```javascript
// Wrong — the order id comes from the URL, and the query is built by concatenation
const rows = db.query("SELECT * FROM orders WHERE id = " + req.params.id);
```

```javascript
// Right — the value is a parameter, so it can never be read as query text
const rows = db.query("SELECT * FROM orders WHERE id = ?", [req.params.id]);
```

The question that finds these: **what part of this does an attacker control?**

## 4. Context Boundaries

Most disappointing answers are answers to a question the assistant could not see the whole
of. Before blaming the model, ask what it actually had.

```text
The assistant usually can see:        The assistant usually cannot see:
  - the file you have open              - the rest of the repository
  - what you selected                   - your database contents
  - your prompt, and this session       - what your team decided last week
  - files you explicitly attach         - your ticket, unless you paste it
                                        - the version you are actually running
```

So supply the missing pieces:

```text
# Wrong — nothing here says which project, which rules, or which version
"How do I cancel an order?"
```

```text
# Right — the assistant has the domain rule, the constraint and the artifact
"In OrderDesk, an order has many shipments. Cancellation must be refused once
 ANY shipment has dispatched, and the refusal message must name that shipment.
 Here is the current cancellation function: <paste>.
 Change only this function. Do not change its signature."
```

> **Tip.** "Change only this function" and "do not change the signature" prevent most
> over-scoping. Bound the change in the prompt, not in the review.

Long sessions drift. If an answer contradicts something you established twenty messages
ago, restate the constraint rather than arguing with it — and check the answer against your
own code, which is the only authority in the room.

## 5. Prompt Patterns

**Explain unfamiliar code.** Ask for the shape first, then the risk:

```text
"Explain what this function does in three sentences, then list the inputs that
 would make it behave unexpectedly. Do not suggest changes yet."
```

**Debug a real failure.** Give evidence, not a description of evidence:

```text
"Cancelling an order fails with this error: <paste the exact error and stack>.
 Here is the function: <paste>. Here is what I already checked: the order exists
 and has no dispatched shipment.
 List the three most likely causes, most likely first, and for each one tell me
 what I could check to confirm or rule it out."
```

Asking for *causes to check* rather than *a fix* is the single highest-value habit in this
unit. It keeps you diagnosing instead of accepting.

**Review your own work.** The assistant is often better as a critic than an author:

```text
"Review this change against these acceptance criteria: <paste>.
 Name any case the criteria cover that the code does not handle.
 Do not rewrite it — list the gaps."
```

**Widen your own thinking:**

```text
"What edge cases does this cancellation rule miss, given that an order can have
 several shipments and a cancellation window that closes at dispatch?"
```

## 6. Verification

A suggestion is unverified until something outside the assistant agrees with it. Three
things count; the assistant's own reassurance is not one of them.

| Evidence | Answers | Good for |
|---|---|---|
| A test that fails before and passes after | "Does it do what I asked?" | Logic and edge cases |
| Observed behaviour — you ran it and watched | "Does it work in the real system?" | Integration, UI, error paths |
| A primary source — official docs for your version | "Does this API exist and mean this?" | Any unfamiliar call or option |

```text
# Wrong — not verification, just agreement
"I asked if it was correct and it said yes."

# Right — evidence that exists independently of the assistant
"Added a test for an order with one of two shipments dispatched. It failed
 with the suggested version and passes with `every(...)`. Checked the docs for
 our version: `Array.prototype.every` behaves as assumed on an empty array,
 which is the empty-order case."
```

### The spec → test → generate → review loop

```text
1. SPEC      Write down what "done" means, in checkable terms.
             Usually the acceptance criteria you already have.

2. TEST      Decide how you will know it works — a test, or the exact steps
             you will perform and what you expect to see. Before generating.

3. GENERATE  Prompt with the spec, the constraints and the relevant code.

4. REVIEW    Read every line. Ask of each: do I understand why this is here?
             Run the check from step 2. Check unfamiliar calls in the docs.
             ── if it fails, back to step 3 with what you learned ──

5. RECORD    Write down what you accepted, what you rejected, and the evidence.
```

Step 2 before step 3 is the part people skip, and it is the part that works. Deciding your
check before you see the answer stops the answer from defining what "correct" means.

## 7. Recording What You Did

For every AI-assisted change, three things go on the record: what you accepted and why,
what you rejected and why, and the evidence. Your short assignment supplies an
`AI_USAGE.md` template for this; the content is what matters, not the format.

```text
## Accepted — refusal check rewritten as `shipments.every(s => s.dispatched)`
Evidence: new test "one of two shipments dispatched" fails before, passes after.
Verified `Array.prototype.every` on an empty array against the MDN reference.

## Rejected — suggested `orderService.cancelAllPending(...)`
Reason: no such method. Searched the repository; the assistant invented it.
Wrote the loop by hand instead.

## Rejected — suggested removing the null check "since the id is always present"
Reason: the id comes from the URL, so it is not always present. Kept the check
and added a test for a missing id.
```

The rejected entries are the valuable ones. They are the evidence that you reviewed rather
than accepted, and they are what a reviewer looks at first.

> **Real-world use.** Clients increasingly ask how AI was used on their code. A team that
> can show what was accepted, what was rejected and what verified each one is in a very
> different position from a team that cannot say.

## 8. Common Problems

### The suggested method does not exist

A hallucinated API. Search the codebase and the official docs for your version. If neither
has it, it is invented — write it yourself or find the real call.

### It works on my example and fails on the real data

You verified the happy path. Go back to the acceptance criteria and test the case that
should be *refused*, the empty case, and the boundary.

### The assistant contradicts what it said earlier in the session

Context drift. Restate the constraint explicitly, and check the new answer against your own
code rather than against the earlier answer.

### I asked for a small fix and got the whole file rewritten

Over-scoping. Bound it in the prompt — "change only this function", "do not change the
signature" — and read the diff before accepting. Never accept a change whose size you did
not expect.

### The reviewer asked how it works and I could not answer

You accepted without step 4. This is the failure the module cares about most: work you
cannot explain earns no credit. Go back through the change line by line before you request
review again.

### The cited documentation link does not exist

A confident fabrication. Fabricated citations are common. Follow every link; an
unfollowable citation is not evidence.

## 9. Verification Checklist

Before you accept an AI-assisted change:

- [ ] I can explain every line, including why it is there.
- [ ] Every unfamiliar call was checked against the official docs for my version.
- [ ] A test or an observed behaviour confirms it — not the assistant's own assurance.
- [ ] The edge case from the acceptance criteria is covered, not only the happy path.
- [ ] Nothing outside the intended scope was changed.
- [ ] I asked what an attacker controls, and no input reaches a query or a command unescaped.
- [ ] No secret, credential or real customer data was pasted into the prompt.
- [ ] Accepted and rejected suggestions are recorded with their evidence.

## 10. Knowledge Check

1. Why is the assistant's confidence useless as a signal of correctness?
2. Give the symptom that distinguishes a hallucinated API from a plausible-but-wrong
   implementation, and how you would catch each.
3. The assistant suggests refusing cancellation when `order.shipments.length > 0`. What
   OrderDesk rule does that get wrong, and what test would expose it?
4. List three things the assistant cannot see that would change its answer, and say how
   you supply each.
5. Rewrite "why is my cancellation broken?" as a debugging prompt that would get a useful
   answer, and say what each addition contributes.
6. Why does the loop put the test step before the generate step? What goes wrong if you
   swap them?
7. Name the three kinds of evidence that count as verification, and one thing that does not.
8. Which is more useful to a reviewer — your list of accepted suggestions or your list of
   rejected ones, and why?

## 11. Further Reading

- The documentation for the approved AI coding assistant — especially what it sends as
  context and what your organisation's licence permits.
- [OWASP Top 10](https://owasp.org/www-project-top-ten/) — the categories most worth
  checking generated code against.
- [MDN Web Docs](https://developer.mozilla.org/) — a primary source to practise verifying
  against; the habit matters more than this particular reference.

Review: [Agile, Git & AI-Assisted Development Foundations — Study Guide](index.md). The lab for this unit is
[Lab 04 — Provoke the failure modes, then work the loop](lab-04.md), and the syllabus map is in [Agile, Git & AI-Assisted Development Foundations — Appendix](appendix.md).
