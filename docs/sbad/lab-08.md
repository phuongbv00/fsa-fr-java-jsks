# Lab 08 — A test suite with real security paths

**Duration:** 150 min · **Objectives:** SBAD-K4

## Objectives

After this lab, learners can:

- Choose the smallest test that answers the question.
- Test controllers with slices and repositories against real PostgreSQL.
- Cover negative security paths end to end.

## Before you start

- You have read [Testing Spring Applications](testing-spring-applications.md).
- Lab 07 is complete.
- Docker is running, for Testcontainers.

## Steps

1. **Classify what you have.** In `docs/testing.md`, list every behaviour worth testing and the
   test type you will use, with one line of justification each.

2. **Write plain JUnit tests** for the service layer, using the in-memory repository and a fixed
   `Clock`. No Spring context. These should be the largest group.

3. **Write `@WebMvcTest` tests** for two controllers with the service mocked, covering: a
   successful read; a 404; a validation failure asserting exact `fieldErrors[].field` paths.

4. **Write `@DataJpaTest` tests** with `@AutoConfigureTestDatabase(replace = NONE)` and a
   PostgreSQL container initialised from your DBF `schema.sql`.

5. **Show why H2 is not enough.** Run one repository test against H2 and record what differs — a
   type, a constraint, or a function that behaves differently. Put it in `docs/testing.md`.

6. **Write `@SpringBootTest` integration tests** for the full flow: log in, place an order, read
   it back, cancel it as staff.

7. **Cover the negative security paths.** At minimum: no token; expired token; token signed with
   another secret; a customer reading another customer's order; a customer attempting a
   staff-only action.

8. **Assert the error contract,** not only the status, in at least three failure tests.

9. **Make it fast.** One shared container and one shared context across integration tests.
   Record the suite time before and after in `docs/testing.md`.

10. **Prove the suite catches a regression.** Remove the ownership check, run the suite, and
    record which test fails and what it says. Restore it.

## Acceptance

- [ ] `docs/testing.md` classifies every behaviour by test type with justification.
- [ ] Plain JUnit tests are the largest group and need no Spring context.
- [ ] `@WebMvcTest` covers success, 404 and a validation failure with exact field paths.
- [ ] Repository tests run against PostgreSQL via Testcontainers, not H2.
- [ ] The H2-versus-PostgreSQL difference is recorded concretely.
- [ ] Five negative security paths are tested and pass.
- [ ] Three failure tests assert the `ApiError` shape.
- [ ] Suite time before and after sharing the context is recorded.
- [ ] Removing the ownership check fails a named test.

---

Next: [Containerization, Configuration & Observability](containerization-and-observability.md).
