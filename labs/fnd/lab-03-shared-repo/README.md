# OrderDesk — shared repository (Lab 03)

Lab 03 is done in pairs against a **shared** repository with `main` protected, so that pushing
to `main` is refused and every change arrives through a pull request.

## What is here

```
seed/                the contents the shared repository starts from
stories/story-a.md   one pair member takes this
stories/story-b.md   the other takes this
```

The two stories change **the same function in the same file** — `seed/src/returns.js`. That is
deliberate: whoever merges second gets a real conflict to resolve, which is step 9 of the lab.

## For the trainer — one-time setup per pair

1. Create an empty repository on the class hosting platform, one per pair.
2. Push the contents of `seed/` to it as the first commit on `main`.
3. Protect `main`: require a pull request, and disallow direct pushes. Step 5 of the lab
   depends on this refusal actually happening.
4. Add both trainees as collaborators.
5. Give one of them Story A and the other Story B.

## For trainees

Clone the repository your trainer gives you, confirm `git remote -v` shows `origin`, and open
the story you were assigned. Do not read your partner's story until you have opened your pull
request — reviewing it cold is part of the exercise.
