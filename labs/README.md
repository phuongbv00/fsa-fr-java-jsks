# Lab materials

Starter material for the labs that need something supplied. Most labs scaffold their own
project — with Vite or a Maven archetype — and are not listed here.

The Foundations labs all run in **groups of four or five**. Lab 03 needs one shared repository
per group; the rest are done individually but sitting together, so the group can unblock each
other and compare results.

| Lab | Folder | What it gives you |
|---|---|---|
| FND Lab 01 | [`fnd/lab-01-stakeholder-brief`](fnd/lab-01-stakeholder-brief) | One page of raw meeting notes about returns and refunds, deliberately vague and partly contradictory, plus the worksheet each group fills in |
| FND Lab 02 | [`fnd/lab-02-orderdesk-seed`](fnd/lab-02-orderdesk-seed) | A small folder of text and source files with no `.git`, to make a repository from |
| FND Lab 03 | [`fnd/lab-03-shared-repo`](fnd/lab-03-shared-repo) | The contents a shared repository starts from, plus five stories that collide on purpose — one per group member |
| FND Lab 04 | [`fnd/lab-04-starter-project`](fnd/lab-04-starter-project) | A runnable project with passing tests, for the AI-assisted development lab |
| DBF, JCF, SBAD | [`dbf/orderdesk-schema`](dbf/orderdesk-schema) | The OrderDesk order schema and seed data — the database every module from Database Foundations onward reads and writes |

## Getting them

Clone the whole repository, or download a single folder from the GitHub page.

```bash
git clone https://github.com/phuongbv00/fsa-fr-java-jsks.git
cd fsa-fr-java-jsks/labs/fnd/lab-04-starter-project
```

For Lab 02 and Lab 04 you want the folder **copied out** to somewhere of your own, so the work
you do is yours and not a change to this repository.

```bash
cp -r fsa-fr-java-jsks/labs/fnd/lab-02-orderdesk-seed ~/orderdesk
cd ~/orderdesk
```

Lab 02 in particular expects **no `.git` directory** — you create the repository yourself in
step 1. Copying the folder out gives you exactly that.

The order schema is used for the rest of the programme, so copy it out once and keep it:

```bash
cp -r fsa-fr-java-jsks/labs/dbf/orderdesk-schema ~/orderdesk-schema
~/orderdesk-schema/rebuild.sh
```
