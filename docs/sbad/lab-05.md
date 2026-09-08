# Lab 05 — Validation and one error contract

**Duration:** 120 min · **Objectives:** SBAD-K2

## Objectives

After this lab, learners can:

- Validate request bodies, including nested collections.
- Produce one consistent error body for the whole API.
- Map domain exceptions to correct status codes in one place.

## Before you start

- You have read [Validation & Error Contracts](validation-and-error-contracts.md).
- Lab 04 is complete.

## Steps

1. **Annotate every request DTO.** Constraints on each field with messages written for a person,
   not a developer. Cascade into nested collections with `@Valid`.

2. **Prove cascading matters.** Remove `@Valid` from the nested list, post a body with an invalid
   line, and record that no error is reported. Restore it and show `lines[0].sku` appearing.

3. **Define `ApiError`** with timestamp, status, error, message, path and field errors.

4. **Write `@RestControllerAdvice`** handling: validation failure, malformed JSON, not found,
   conflict, unprocessable, and a catch-all.

5. **Prove the catch-all leaks nothing.** Throw a `RuntimeException` whose message contains a
   fake connection string. Record the response body — it must not contain it — and the log line,
   which must.

6. **Map every domain exception.** Each gets the status from the note's table. Record the
   mapping in `docs/errors.md` with one line of justification each.

7. **Write a custom constraint** — `@ValidSku` — with its validator, returning true for null.
   Explain in a comment why null is `@NotNull`'s job.

8. **Test the contract.** For each of six failure kinds, a test asserting both the status and
   the `ApiError` shape. At least one asserts the exact `fieldErrors[].field` paths.

9. **Curl every failure.** Capture the request and response for all six into `docs/errors.md`.

## Acceptance

- [ ] Every request DTO is annotated and cascades into nested collections.
- [ ] The missing-`@Valid` demonstration is recorded, before and after.
- [ ] One `ApiError` shape is returned by every error path.
- [ ] Six exception kinds are handled, each mapped to a justified status.
- [ ] The catch-all logs the detail and returns a fixed message; both are recorded.
- [ ] `@ValidSku` exists, returns true for null, and is tested.
- [ ] Six tests assert status and body shape; one asserts exact field paths.
- [ ] `docs/errors.md` shows six real request/response pairs.

---

Next: [Authentication with Spring Security & JWT](authentication-and-jwt.md).
