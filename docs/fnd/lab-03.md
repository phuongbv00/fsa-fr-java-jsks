# Lab 03 — Pull requests, review and a rehearsed conflict

**Duration:** 75 min

You work in your group of four or five for this lab, against one shared repository. Everyone
authors a change and everyone reviews one, so nobody spends the session only writing or only
reading.

Everything up to the merge queue happens **in parallel** — do not wait for each other.

## Objectives

By the end of this lab you will be able to:

- Push a branch and open a pull request a reviewer can act on without asking questions.
- Review a peer's pull request with comments that name a line and a consequence.
- Revise a pull request in response to review and show what changed.
- Resolve a merge conflict deliberately, and verify the resolution rather than assume it.
- Recognise a rejected push and take the correct next step.

## Before you start

- You have read [Pull Requests & Collaborative Workflow](pull-requests-and-conflicts.md).
- Your group has access to one **shared OrderDesk repository** on the class hosting platform,
  with `main` protected so direct pushes are refused. It starts from
  [`labs/fnd/lab-03-shared-repo/seed`](https://github.com/phuongbv00/fsa-fr-java-jsks/tree/main/labs/fnd/lab-03-shared-repo/seed).
- Each of you has **one story**, [A to E](https://github.com/phuongbv00/fsa-fr-java-jsks/tree/main/labs/fnd/lab-03-shared-repo/stories). Every story changes the same function
  on purpose, so everyone who merges after the first gets a real conflict. Do not read the
  others' stories until your own pull request is open.
- As a group, agree two things now and write them where everyone can see: the **review ring**
  — who reviews whom, so each person reviews exactly one pull request and is reviewed once —
  and the **merge order**, numbered 1 to 5.
- You have cloned the repository and `git remote -v` shows `origin`.

## Steps

1. **Everyone, in parallel.** Run `git switch main`, `git pull`, then create your branch
   named for your story and carrying its ticket id. Confirm with `git branch` that you are on it.

2. Implement your story in two or three focused commits. Before pushing, run
   `git log --oneline` and check each subject would mean something to the person reviewing you.

3. Push with `git push -u origin <your-branch>`. Read the output — it prints the URL to open
   the pull request.

4. Open the pull request. Write a description with **What**, **Why**, **How to verify** as
   numbered steps, and a **Notes for the reviewer** line naming the part you are least sure
   about. Request your reviewer from the ring.

5. Try `git switch main`, commit a trivial change there, then `git push origin main`. The push
   is **refused** by the protected branch. Read the message, then put `main` back where the
   remote has it with `git reset --keep origin/main` (it refuses if that would lose uncommitted
   work), and write down in one sentence why this rule exists. Switch back to your branch.

6. Review the pull request assigned to you by the ring. Leave at least four comments: one
   **blocking**, one **suggestion**, one **question**, and one saying what they did well. Every
   comment must name a line and say what would go wrong — no comment may be "this is confusing".

7. Read the comments on your own pull request and reply to **every one**, including the ones
   you disagree with. Where you disagree, say why rather than silently changing it.

8. Revise your branch as new commits — do not amend, so your reviewer can see what changed —
   and push. Confirm the new commits appear in the pull request.

9. **Now the merge queue, and this part is deliberately serial.** Person 1 in the merge order
   merges. Their pull request goes in cleanly, because `main` has not moved.

10. **Everyone else, at the same time:** run `git fetch` then `git merge origin/main` on your
    branch. You get `CONFLICT (content)` in `src/returns.js`. Open it and identify which side
    is yours and which is incoming **before** editing anything.

11. Resolve it: decide what the function should do when **both** rules apply — that is a
    product decision, and it is usually neither side verbatim. Delete all three markers, add a
    comment saying why the surviving version is right, then `git add` and `git commit`.

12. **Verify the resolution.** Check the behaviour both stories asked for, not just that the
    file still parses. If only one of the two works, your resolution kept half of each change —
    go back to step 11.

13. Push, and let person 2 merge. Persons 3 onward repeat steps 10 to 12 against the new
    `main`. Each round is smaller than the last, because the guards accumulate in one place.

14. When time is called, the group runs `git switch main`, `git pull`, and
    `git log --oneline --graph` together. Read the shape out loud: who branched from where,
    and where each merge landed.

15. Search the repository for `<<<<<<<` and confirm there are no results. Delete your merged
    branches locally and on the remote.

## Acceptance

- [ ] Every member opened one pull request, each with What, Why and numbered verification steps.
- [ ] The review ring was followed: each member reviewed exactly one and was reviewed once.
- [ ] A push to protected `main` was attempted, refused, and you can say why.
- [ ] You left four or more review comments, each naming a line and a consequence.
- [ ] One of your comments was explicitly marked as blocking.
- [ ] Every comment on your own pull request has a reply.
- [ ] Your revision is visible as additional commits, not an amended history.
- [ ] At least two members resolved a real conflict, each with a comment saying why.
- [ ] After each resolution, both affected stories' behaviours were observed working.
- [ ] No `<<<<<<<` marker exists anywhere in the repository.
- [ ] The group can describe the shape of `git log --graph` and say what caused each merge.

> **Note.** You may not reach the end of the merge queue in 75 minutes, and that is expected —
> a queue that gets slower as it lengthens is the thing worth noticing. Stop where the trainer
> calls time and do step 14 with whatever has landed.

---

Next: [AI-Assisted Development](ai-assisted-development.md).
