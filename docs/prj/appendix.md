# Mock Project (Capstone) — Appendix

> See [Mock Project (Capstone) — Study Guide](index.md).

## 1. Unit Map

| Unit | Focus | Objectives |
|---|---|---|
| 1 | Kickoff and scope | PRJ-K1, PRJ-K2 |
| 2 | Sprint 1 — vertical slice | PRJ-K3 |
| 3 | Sprint 2 — core features, change request | PRJ-K1, PRJ-K2, PRJ-K3 |
| 4 | Sprint 3 — hardening and delivery | PRJ-K3, PRJ-K4 |
| 5 | Guided revision | PRJ-K1, PRJ-K2 |
| 6 | Final review | PRJ-K1, PRJ-K2, PRJ-K4 |

## 2. Objective Coverage

| Code | Objective | Demonstrated by |
|---|---|---|
| PRJ-K1 | Product definition and technical design | `docs/product.md`, `docs/architecture.md`, the backlog |
| PRJ-K2 | Iterative team delivery | Sprint events, backlog history, reviewed pull requests |
| PRJ-K3 | Product implementation and quality | The running product, its tests, its security controls |
| PRJ-K4 | Individual engineering ownership | The defence, Git history, the observed change |

## 3. Where Each Module Is Used

| Module | Used for |
|---|---|
| FND | Scrum events, user stories, acceptance criteria, Git, pull requests, AI usage declaration |
| DBF | The normalized schema, constraints, indexes, transactions |
| JCF | Domain types, repositories, tests, persistence diagnosis |
| SBAD | The API, DTO boundary, transactions, validation, security, containerization |
| FEF | Semantic markup, accessibility, typed API access, the four states |
| RAD | Components, routing, forms, session state, component tests |

## 4. Definition of Done — a starting point

Agree your own in unit 1; this is the floor, not the ceiling.

- [ ] Acceptance criteria met and demonstrated
- [ ] Code reviewed and approved by someone who did not write it
- [ ] Automated tests written and passing in CI
- [ ] No new compiler or linter warnings
- [ ] Failure paths handled, not only the happy path
- [ ] Authorization enforced server-side where the story needs it
- [ ] Documentation updated in the same pull request
- [ ] Merged to the main branch and running on the shared environment

## 5. Sprint 1 — Vertical Slice Checklist

- [ ] One feature chosen, narrow enough to finish
- [ ] Schema created by a script that runs from an empty database
- [ ] Endpoint implemented with a DTO boundary
- [ ] Validation and one consistent error contract
- [ ] Authentication working; the endpoint authorized
- [ ] Screen implemented with loading, empty, success and error states
- [ ] At least one test at each layer
- [ ] Demonstrated end to end at Sprint Review 1

## 6. Security Checklist

Carried from Spring Boot API Development unit 7; the final review checks it.

- [ ] Passwords hashed with BCrypt
- [ ] Tokens signed with a secret from the environment, and they expire
- [ ] Rules deny by default
- [ ] Identity taken from the token, never from a request parameter
- [ ] Ownership checked on every user-owned resource
- [ ] Server-side validation on every input
- [ ] Errors reveal nothing internal
- [ ] No secret in any tracked file, image layer or log line

## 7. Reproducible Setup Checklist

Part B of the final review depends on this.

- [ ] `README.md` lists prerequisites with versions
- [ ] One command starts the whole system
- [ ] Seed data is loaded by a script
- [ ] Configuration is environment-based, with an `.env.example`
- [ ] Test credentials for each role are documented
- [ ] Verified from a fresh clone on a machine that never ran it

## 8. Final Review Evidence

| Item | Form |
|---|---|
| Product definition | `docs/product.md` |
| Backlog with acceptance criteria | The backlog tool, with history |
| Architecture and trade-offs | `docs/architecture.md` |
| Data model | `docs/data-model.md` with an ERD |
| API contract | Published OpenAPI |
| Change request decision | `docs/decisions.md` |
| Test evidence | CI results |
| Individual contribution | Git history, authored and reviewed pull requests |
| Working product | Running from a fresh clone |

## 9. Common Ways a Capstone Goes Wrong

| Pattern | What it looks like | Do instead |
|---|---|---|
| Horizontal planning | Nothing works until week four | Vertical slice in sprint 1 |
| Big-bang integration | Branches merged on the last day | Integrate daily |
| Silent scope absorption | The change request absorbed by overtime | Assess, renegotiate, record |
| Siloed ownership | One person per layer; nobody can defend the whole | Rotate roles, review across layers |
| Evidence archaeology | Reconstructing decisions in unit 5 | Record decisions as you make them |
| Untested happy path only | The demo works, one wrong input breaks it | Failure paths in the Definition of Done |
| Works on one laptop | The demonstration cannot start | Rehearse from a fresh clone |

## 10. Primary Sources

- [Scrum Guide](https://scrumguides.org/scrum-guide.html)
- [Spring Boot reference](https://docs.spring.io/spring-boot/index.html)
- [React documentation](https://react.dev/)
- [PostgreSQL 18 documentation](https://www.postgresql.org/docs/current/index.html)
- [OWASP API Security Top 10](https://owasp.org/API-Security/editions/2023/en/0x11-t10/)

---

Back to [Mock Project (Capstone) — Study Guide](index.md).
