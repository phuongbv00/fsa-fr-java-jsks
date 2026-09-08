# Lab 03 — Pull requests, review and a rehearsed conflict

**Duration:** 75 min · **Objectives:** FND-K2

You work in pairs for this lab. Both of you author a change and both of you review one, so
neither of you spends the session only writing or only reading.

## Objectives

After this lab, learners can:

- Push a branch and open a pull request a reviewer can act on without asking questions.
- Review a peer's pull request with comments that name a line and a consequence.
- Revise a pull request in response to review and show what changed.
- Resolve a merge conflict deliberately, and verify the resolution rather than assume it.
- Recognise a rejected push and take the correct next step.

## Before you start

- You have read [Pull Requests & Collaborative Workflow](pull-requests-and-conflicts.md).
- The trainer has given both of you access to the **shared OrderDesk repository** on the
  class hosting platform, with `main` protected so direct pushes are refused.
- The trainer has told you which **two stories** you and your pair partner will implement.
  They deliberately touch the same file, so a conflict is guaranteed.
- You have cloned the repository and `git remote -v` shows `origin`.

## Steps

1. Both of you: run `git switch main`, `git pull`, then create your own branch named for
   your story and carrying its ticket id. Confirm with `git branch` that you are on it.

2. Implement your story in two or three focused commits. Before pushing, run
   `git log --oneline` and check each subject would mean something to your partner.

3. Push with `git push -u origin <your-branch>`. Read the output — it prints the URL to
   open the pull request.

4. Open the pull request. Write a description with **What**, **Why**, **How to verify** as
   numbered steps, and a **Notes for the reviewer** line naming the part you are least
   sure about. Request your partner as reviewer.

5. Try `git switch main` then `git push origin main` with a trivial change. The push is
   **refused** by the protected branch. Read the message, undo your local change, and write
   down in one sentence why this rule exists.

6. Review your partner's pull request. Leave at least four comments: one **blocking**, one
   **suggestion**, one **question**, and one saying what they did well. Every comment must
   name a line and say what would go wrong — no comment may be "this is confusing".

7. Read the comments on your own pull request and reply to **every one**, including the
   ones you disagree with. Where you disagree, say why rather than silently changing it.

8. Revise your branch as new commits — do not amend, so your reviewer can see what changed
   — and push. Confirm the new commits appear in the pull request.

9. One of you merges first. The other now runs `git fetch` and `git merge origin/main` on
   their branch and gets `CONFLICT (content)`. Open the file and identify which side is
   yours and which is incoming **before** editing anything.

10. Resolve it: decide which behaviour is correct for OrderDesk — it may be neither side
    exactly — delete all three markers, and add a comment saying why the surviving version
    is right. Run `git status` to confirm nothing else is still conflicted, then
    `git add` and `git commit`.

11. **Verify the resolution.** Run the change and check the behaviour both stories asked
    for, not just that the file compiles. If only one of the two behaviours works, your
    resolution kept half of each change — go back to step 10.

12. Push and merge the second pull request. Both of you: `git switch main`, `git pull`, and
    confirm `git log --oneline --graph` shows both stories in the shared history.

13. Search the repository for `<<<<<<<` and confirm there are no results. Delete your
      merged branches locally and on the remote.

## Acceptance

- [ ] Two pull requests were opened, each with What, Why and numbered verification steps.
- [ ] A push to protected `main` was attempted, refused, and you can say why.
- [ ] You left four or more review comments, each naming a line and a consequence.
- [ ] One of your comments was explicitly marked as blocking.
- [ ] Every comment on your own pull request has a reply.
- [ ] Your revision is visible as additional commits, not an amended history.
- [ ] A real conflict was resolved, and the resolution carries a comment saying why.
- [ ] Both stories' behaviours were observed working after the resolution.
- [ ] No `<<<<<<<` marker exists anywhere in the repository.
- [ ] `main` contains both stories, and both feature branches are deleted.
