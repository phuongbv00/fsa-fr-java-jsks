# Lab 02 — Build, branch and recover an OrderDesk repository

**Duration:** 150 min

The longest lab in the module, and the one that everything in session 3 depends on. Type
the commands rather than pasting them, and read the output of each before the next.

## Objectives

By the end of this lab you will be able to:

- Create a repository and make focused commits with messages that explain why.
- Stage part of a file's changes to separate two unrelated edits.
- Read history and identify what a given commit changed.
- Create, merge and delete a branch, and recognise which kind of merge occurred.
- Write ignore rules, and fix a rule that is not taking effect.
- Recover a lost commit, a wrong message and a bad reset without losing work.

## Before you start

- Git 2.40 or later: `git --version`.
- `user.name` and `user.email` set globally — see section 5 of
  [Agile, Git & AI-Assisted Development Foundations — Study Guide](index.md).
- You have read [Git Fundamentals](git-fundamentals.md).
- You have the **OrderDesk seed folder**: a small set of plain text and source files with
  no `.git` directory — you make it a repository yourself in step 1. Copy it out of
  [`labs/fnd/lab-02-orderdesk-seed`](https://github.com/phuongbv00/fsa-fr-java-jsks/tree/main/labs/fnd/lab-02-orderdesk-seed) to a folder of your own,
  so the history you create is yours.
- A terminal, and an editor you can open the folder in.

Nothing here touches a remote. You work entirely locally until session 3.

## Steps

1. Open a terminal in the seed folder and run `git status`. Read the error. Then run
   `git init` and `git status` again. You should now see every seed file listed as
   untracked.

2. Before staging anything, create `.gitignore` with rules for `/dist/`, `node_modules/`,
   `.env` and `.DS_Store`. Run `git status` again and confirm those entries have
   disappeared from the untracked list.

3. Make your **first commit**: stage `.gitignore` and the source files, and commit with a
   subject line and a body. Run `git log --oneline` and confirm exactly one commit exists.

4. Open the cancellation source file and make **two unrelated changes** — change the
   refusal message, and separately fix an unrelated typo elsewhere in the file. Run
   `git add -p` and stage only the refusal-message hunk. Run `git status` and confirm the
   same file appears as both staged and modified. That split is the point of the exercise.

5. Commit the staged hunk with a message explaining why the message changed. Then commit
   the typo separately. `git log --oneline` now shows three commits, each describable in
   one sentence without the word "and".

6. You have just noticed a spelling mistake in the last commit's subject. Fix it with
   `git commit --amend`, then run `git log --oneline` and confirm the commit count is
   still three and the message is corrected.

7. Run each of `git log --oneline --graph --decorate`, `git show HEAD`, `git log -p -1`
   and `git log --oneline -- <the cancellation file>`. For each, write one line saying
   what it told you that the others did not.

8. Create a branch `feature/refund-reason` with `git switch -c`, add a refund-reason field
   to the returns file, and commit it. Run `git log --oneline --graph --decorate --all`
   and identify where the branch label sits relative to `main`.

9. Switch back to `main` and merge the branch. Look at the output: it says
   `Fast-forward`. Confirm with `git log --graph` that the history is a straight line, and
   say why no merge commit was created. Delete the branch with `git branch -d`.

10. Now force the other kind of merge. Create `feature/courier-timeout`, commit a change
    there; switch to `main` and commit a change to a **different** file; then merge. The
    output now names a merge commit. Draw or describe the shape from `git log --graph` and
    say what made this merge different from step 9.

11. Add a file named `.env` containing `API_KEY=notreal`, then run `git status` — it is
    correctly ignored. Now break it: run `git add -f .env`, commit, and add another line to
    `.env`. Run `git status` and observe that the ignore rule no longer protects it.
    Diagnose it with `git check-ignore -v .env`, then fix it with `git rm --cached .env`
    and commit. Confirm `.env` is untracked and still on disk.

12. **Lose a commit on purpose.** Commit a small change you would mind losing, note its
    subject, then run `git reset --hard HEAD~1`. Confirm with `git log --oneline` that it
    is gone. Now find it with `git reflog`, and recover it with
    `git switch -c recovered <hash>`. Confirm the change is back in your working files.

13. Merge `recovered` into `main`, delete the branch, and run
    `git log --oneline --graph --decorate` one final time. Read the whole history top to
    bottom and check it tells a story a stranger could follow.

14. Leave the repository clean: `git status` must report nothing to commit and no untracked
    files other than `.env`. This is the state session 3 starts from.

## Acceptance

- [ ] `git log --oneline` shows at least eight commits.
- [ ] No commit message subject needs the word "and" to describe it.
- [ ] At least two commits have a body explaining why the change was made.
- [ ] Two commits came from splitting one file's changes with `git add -p`.
- [ ] `.gitignore` is committed and covers `/dist/`, `node_modules/`, `.env` and `.DS_Store`.
- [ ] `.env` exists on disk, is untracked, and `git check-ignore -v .env` names the rule.
- [ ] The history contains one fast-forward merge and one merge commit, and you can point
      at each in `git log --graph`.
- [ ] A commit destroyed by `git reset --hard` was recovered via `git reflog`, and its
      change is present in the final history.
- [ ] `git status` reports a clean working tree.
- [ ] You can explain, out loud, what any commit in your history changed and why.
