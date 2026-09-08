# Lab 05 — Exception boundaries and a test suite

**Duration:** 150 min

## Objectives

By the end of this lab you will be able to:

- Choose checked or unchecked deliberately and place a boundary where it helps.
- Preserve a cause when translating an exception.
- Cover happy paths, edge cases and failures with JUnit 5.
- Use try-with-resources so nothing leaks on the failure path.

## Before you start

- You have read [Exceptions & Unit Testing](exceptions-and-testing.md).
- Lab 04 is complete.

## The brief

Add a `CatalogLoader` that reads a product CSV from disk into `List<Product>`, and an
`OrderService` that uses the catalog and an `OrderRepository`.

## Steps

1. **Design the exception types.** In `docs/exceptions.md`, a table of every failure the loader
   and service can meet: what it is, checked or unchecked, and one sentence of justification.
   At least one of each must be present and defensible.

2. **Implement `CatalogLoader`** reading a file with try-with-resources. A missing file, an
   unreadable file and a malformed row are three distinct outcomes — do not collapse them.

3. **Translate at the boundary.** `IOException` must not escape the loader. Wrap it in a domain
   exception **with the cause attached**, and include the path in the message.

4. **Prove the cause survives.** Write a test asserting `e.getCause()` is the `IOException`, not
   just that an exception was thrown.

5. **Implement `OrderService.place(order)`** which validates against the catalog: an unknown SKU
   is a domain failure, an inactive product is a different one.

6. **Write the suite.** For every rule, three tests — happy path, edge case, failure. Use
   `@Nested` to group them and `@DisplayName` to state behaviour.

7. **Parameterise the edge cases.** Use `@ParameterizedTest` with `@CsvSource` for quantity and
   price boundaries rather than copying test methods.

8. **Assert on messages** wherever the message carries information a caller needs — the offending
   SKU, the file path.

9. **Prove nothing leaks.** Write a test where parsing throws midway through a file, and assert
   the reader was closed. A counting wrapper around the stream is the simplest way.

10. **Read a real trace.** Trigger a nested failure, paste the full stack trace into
    `docs/exceptions.md`, and annotate it: which line is the real cause, which is the first line
    of your code, and which frames are noise.

## Acceptance

- [ ] `docs/exceptions.md` classifies every failure as checked or unchecked with justification.
- [ ] Missing file, unreadable file and malformed row are three distinct outcomes.
- [ ] No `IOException` escapes the loader; a test asserts the cause is preserved.
- [ ] There is no empty `catch` block anywhere in the project.
- [ ] Every rule has happy-path, edge-case and failure tests.
- [ ] At least one `@ParameterizedTest` covers a numeric boundary.
- [ ] A test proves the reader closes when parsing throws.
- [ ] `docs/exceptions.md` annotates a real stack trace, naming the true cause.

---

Next: [Collections, Generics, Lambdas & Streams](collections-and-streams.md).
