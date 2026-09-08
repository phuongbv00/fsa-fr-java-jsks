# OrderDesk — shared repository (Lab 03)

Lab 03 runs in groups of four or five, against **one shared repository per group** with `main`
protected, so pushing to `main` is refused and every change arrives through a pull request.

## What is here

```
seed/                 the contents the shared repository starts from
stories/story-a.md    final-clearance items may not be returned
stories/story-b.md    returns outside the 30-day window are refused
stories/story-c.md    a return may not claim more units than were ordered
stories/story-d.md    returns against a cancelled order are refused
stories/story-e.md    returns before anything is delivered are refused
```

Give one story to each member. A group of four uses A to D; a group of five uses all of them.

All five change **the same function in the same file** — `openReturn` in `seed/src/returns.js`.
That is the whole point: the first person to merge goes in cleanly, and everyone after them
gets a real conflict to resolve. Each guard is small, so the conflicts stay readable while
still being genuine.

## For the trainer — one-time setup per group

1. Create an empty repository on the class hosting platform, one per group.
2. Push the contents of `seed/` to it as the first commit on `main`.
3. Protect `main`: require a pull request, and disallow direct pushes. Step 5 of the lab
   depends on that refusal actually happening.
4. Add every group member as a collaborator.
5. Hand out one story each.

The lab asks each group to agree a **review ring** and a **merge order** before they start.
Letting them decide is part of it — but check they have written both down, because the merge
queue falls apart without an agreed order.

## For trainees

Clone the repository your trainer gives you and confirm `git remote -v` shows `origin`. Open
only the story you were given. Do not read the others until your own pull request is open —
reviewing your neighbour's change cold is part of the exercise, and so is discovering at merge
time that four other people edited the same function.
