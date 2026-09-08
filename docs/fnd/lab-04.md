# Lab 04 — Provoke the failure modes, then work the loop

**Duration:** 60 min

The first half of this lab deliberately gets the assistant to be wrong, so you learn what
wrong looks like before it matters. The second half runs the loop properly on one small change.

Work in your group of four or five. Each of you prompts your own assistant and keeps your own
record — but the first half is far more useful compared than done alone, because the same
question produces different wrong answers for each of you. Steps 1 to 4 end with the group
putting its answers side by side.

## Objectives

By the end of this lab you will be able to:

- Provoke and recognise a hallucinated API, an over-scoped answer and a plausible-but-wrong
  implementation.
- Supply the context an assistant is missing, and see the answer change.
- Decide a verification check before generating, and hold the answer to it.
- Verify a suggestion against a test, observed behaviour or a primary source.
- Record accepted and rejected suggestions with the evidence for each.

## Before you start

- You have read [AI-Assisted Development](ai-assisted-development.md).
- The approved AI assistant is installed, signed in, and your licence works. Check this
  now, not at step 3.
- You have the **OrderDesk starter project**: a small runnable project with a cancellation
  function, a returns file, and tests you run with one command. Copy it out of
  [`labs/fnd/lab-04-starter-project`](https://github.com/phuongbv00/fsa-fr-java-jsks/tree/main/labs/fnd/lab-04-starter-project). It needs Node 20 or
  later and installs nothing.
- You have run the test command once and seen it pass. If it does not pass yet, fix that
  before continuing.
- A scratch file open for your notes — you write to it throughout.

> **Note.** Never paste a credential, a real customer record or client-confidential code
> into the assistant. The starter project contains nothing sensitive; your own work later
> might.

## Steps

1. Ask the assistant, with no context at all: *"How do I cancel all pending orders?"* Read
   the answer and check every method it names against the starter project. Record any call
   that does not exist. You have just produced a hallucinated API — note what made it look
   plausible.

2. Ask it to *"fix the cancellation function"* with no constraints, and count how many
   lines and files its answer touches versus how many needed to change. Now ask again with
   *"change only this function, do not change its signature"* and compare. Write one line
   on what the constraint changed.

3. Give it the domain rule it was missing — that an OrderDesk order has many shipments and
   cancellation is refused once any shipment has dispatched — plus the current function.
   Compare this answer with step 2's. Note which specific piece of context changed the
   answer most.

4. Ask it to explain a part of the starter project you do not understand, using the pattern
   from section 5 of the note: shape first, then the inputs that would make it behave
   unexpectedly. Verify one claim it makes by reading the actual code, and record whether
   the claim held.

5. **Stop and compare, as a group.** Put your answers from steps 1 to 4 side by side. Did the
   assistant invent the same call for everyone, or a different one each time? Whose prompt got
   closest, and what was different about it? Write down the one prompt habit the group agrees
   was worth copying — you each use it for the rest of the lab.

6. Now start the real change. The trainer names one **bounded change** to the returns file.
   Write the **spec** first, in your notes: what "done" means, in checkable terms. Do not
   prompt the assistant yet.

7. Write the **check** before generating: either a test you will add, or the exact steps
   you will perform and what you expect to see. Put it in your notes. This is the step that
   makes the rest of the lab work, and the step everyone is tempted to skip.

8. **Generate.** Prompt with the spec, the constraint that only this file changes, and the
   relevant code. Do not run the answer yet.

9. **Review before running.** Read every line and mark any you cannot explain. For each
   unfamiliar call, check the official documentation for the version you are on and record
   what you found. Anything still unexplained after this does not go in.

10. Run your check from step 7. If it fails, go back to step 8 with what you learned — do
   not patch the answer by hand until you understand why it failed. Record each round trip.

11. Provoke one more failure on purpose: ask the assistant to justify its answer with a
    documentation link, then follow the link. Record whether it resolved, and what that
    tells you about citations as evidence.

12. Write up your notes as a record with three parts: what you **accepted** and the
    evidence, what you **rejected** and why, and what you **verified against a primary
    source**. At least two rejections must be real — steps 1 and 11 supply them.

13. Swap records with someone else in your group. Read theirs, then ask them to explain one
    accepted line without looking at it. If they cannot, that line was not reviewed — say so,
    kindly.

## Acceptance

- [ ] A hallucinated call is recorded, with a note on what made it look plausible.
- [ ] The scoped and unscoped versions of the same request are compared in one line.
- [ ] You recorded which piece of missing context changed the answer most.
- [ ] A written spec exists, in checkable terms, dated before your first prompt for it.
- [ ] A written check exists, and it was written before you generated anything.
- [ ] Every line of the accepted change is one you can explain out loud.
- [ ] At least one unfamiliar call was verified against official documentation for your
      version, and what you found is recorded.
- [ ] Your check was run and passed, and each failed round trip is recorded.
- [ ] A cited documentation link was followed, and the result recorded.
- [ ] The record contains at least two genuine rejections with reasons.
- [ ] A peer confirmed you could explain an accepted line without reading it back.
