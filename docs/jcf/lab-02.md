# Lab 02 — A command-line utility from a specification

**Duration:** 120 min

## Objectives

By the end of this lab you will be able to:

- Implement a written specification exactly, including its error cases.
- Choose types deliberately, and handle money without floating point.
- Separate pure logic from I/O so it can be tested.

## Before you start

- You have read [Java Syntax, Types & Methods](language-fundamentals.md).
- Lab 01 is complete and `mvn clean package` succeeds.

## The specification

Write `com.fsa.orderdesk.tools.LineTotals`, run as:

```bash
java -cp target/classes com.fsa.orderdesk.tools.LineTotals lines.csv
```

The input has a header row and then `sku,quantity,unit_price`:

```text
sku,quantity,unit_price
KB-01,3,150000
MS-04,1,99999
```

It must print exactly:

```text
lines: 2
units: 4
total: 549999
```

Rules, all of which must be enforced:

- A quantity that is not a positive whole number is an error.
- A unit price that is negative or unparseable is an error.
- A row with fewer than three fields is an error.
- A trailing empty field must not be silently dropped.
- An empty file (header only) prints zeros, and is not an error.
- Any error prints a message to standard error naming the offending line, and exits with
  status 1. Success exits 0.

## Steps

1. **Separate the pure part.** Put the logic in a package-private method taking
   `List<String>` and returning a result type. `main` does file reading, printing and exit
   codes; nothing else.

2. **Choose your types.** Write one line per field in `docs/types.md` naming the type you chose
   and what you rejected. Money is not `double` — say why.

3. **Return more than one value.** Use a `record` for `lines`, `units` and `total`.

4. **Implement the parsing.** Handle the trailing-empty-field rule; the note names the exact
   `split` argument that matters.

5. **Test the happy path** with a two-row input, asserting all three outputs.

6. **Test every error case** from the specification, asserting the exception and that its
   message names the offending line.

7. **Test the edge cases:** header only; one row; a quantity of `0`; a price of `0`; whitespace
   around values.

8. **Wire up `main`.** Exit 1 with a message on error, 0 on success. Prove it:

   ```bash
   java -cp target/classes com.fsa.orderdesk.tools.LineTotals bad.csv; echo "exit=$?"
   ```

   Capture both runs into `docs/run.txt`.

## Acceptance

- [ ] Output matches the specification exactly, including labels and order.
- [ ] Money is `BigDecimal` constructed from a `String`; no `double` anywhere.
- [ ] The logic method takes a list and returns a record; `main` does only I/O.
- [ ] Every rule in the specification has a test asserting the failure, not just the success.
- [ ] Whitespace around values is handled, and a trailing empty field is not dropped.
- [ ] A header-only file prints zeros and exits 0.
- [ ] `docs/run.txt` shows exit status 1 for a bad file and 0 for a good one.
- [ ] `docs/types.md` justifies each field's type against a rejected alternative.

---

Next: [Object-Oriented Design & Modern Java Types](objects-and-modern-types.md).
