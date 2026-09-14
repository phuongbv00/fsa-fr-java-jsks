# Java Syntax, Types & Methods

> Session 2 · JDK 21 · See [Java Core, JDBC & JPA/Hibernate Persistence — Study Guide](index.md).

## 1. Objectives

By the end of this unit you will be able to:

- Distinguish primitive from reference types and predict which one a variable holds.
- Compare values correctly, choosing between `==` and `equals`.
- Write methods with clear signatures and explain Java's parameter passing.
- Use arrays and `String` operations without the common off-by-one and mutation mistakes.
- Read a `NullPointerException` and identify which reference was null.

## 2. Primitives and References

A variable holds either a value or a reference to an object. Everything else follows.

```java
int a = 5;              // the variable holds 5
int b = a;              // b holds its own copy of 5
b = 7;                  // a is still 5

int[] xs = {1, 2, 3};   // xs holds a reference to an array
int[] ys = xs;          // ys refers to the same array
ys[0] = 99;             // xs[0] is now 99 — one array, two names
```

The eight primitives, with the two that matter most in this programme:

| Type | Size | Use for |
|---|---|---|
| `int` | 32-bit | Counts, quantities, ids in memory |
| `long` | 64-bit | Database ids, epoch milliseconds |
| `double` | 64-bit | Measurements. **Never money** |
| `boolean` | — | True or false |
| `char` | 16-bit | A single UTF-16 unit |
| `byte`, `short`, `float` | | Rarely, in this programme |

```java
// Wrong — money in floating point
double total = 0.1 + 0.2;         // 0.30000000000000004

// Right
BigDecimal total = new BigDecimal("0.1").add(new BigDecimal("0.2"));  // 0.3
```

Note `new BigDecimal("0.1")` with a string. `new BigDecimal(0.1)` takes a `double` and
faithfully preserves the error you were trying to avoid.

### Wrappers and `null`

Every primitive has an object wrapper: `int`/`Integer`, `long`/`Long`. Wrappers can be `null`,
which is why they appear whenever a value may be absent — a nullable database column, for one.

```java
Integer count = null;
int c = count;          // NullPointerException at unboxing, with no obvious cause
```

> **Note.** Prefer the primitive unless absence is genuinely meaningful. `int quantity` cannot
> be null and cannot surprise you; `Integer quantity` can do both.

## 3. Comparing Things

`==` compares what the variable holds. For primitives that is the value; for references it is
the identity of the object.

```java
String a = "KB-01";
String b = "KB-01";
String c = new String("KB-01");

a == b            // true  — both point at the same interned literal
a == c            // false — different objects
a.equals(c)       // true  — same characters
```

The interning is why `==` on strings appears to work and then fails on data read from a
database or a file.

```java
// Wrong — works in a test with literals, fails on real input
if (sku == "KB-01") { ... }

// Right
if ("KB-01".equals(sku)) { ... }
```

Putting the literal first is deliberate: it cannot be null, so the call cannot throw when `sku`
is. `Objects.equals(sku, "KB-01")` is the symmetric alternative.

## 4. Strings

`String` is immutable. Every operation returns a new one.

```java
String sku = "kb-01";
sku.toUpperCase();              // result discarded — sku is unchanged
sku = sku.toUpperCase();        // KB-01
```

Building a string in a loop with `+` creates a new object each iteration:

```java
// Wrong — quadratic, and visible in a profile at a few thousand rows
String csv = "";
for (String sku : skus) { csv += sku + ","; }

// Right
StringBuilder sb = new StringBuilder();
for (String sku : skus) { sb.append(sku).append(','); }
String csv = sb.toString();

// Right, and clearer when you just need a join
String csv = String.join(",", skus);
```

Text blocks make embedded SQL readable, which matters a great deal in units 7 to 9:

```java
String sql = """
        SELECT order_id, placed_at, status
        FROM   orders
        WHERE  customer_id = ?
        ORDER  BY placed_at DESC
        """;
```

## 5. Control Flow

The forms you will use, on OrderDesk data:

```java
// Enhanced for: use this unless you need the index.
for (OrderLine line : order.lines()) {
    total = total.add(line.lineTotal());
}

// switch expression — arrow form, no fall-through, and it must be exhaustive
String label = switch (status) {
    case "placed", "picking" -> "In progress";
    case "dispatched"        -> "On its way";
    case "cancelled"         -> "Cancelled";
    default                  -> throw new IllegalArgumentException("unknown status: " + status);
};
```

```java
// Wrong — classic switch, missing break: 'placed' also prints "On its way"
switch (status) {
    case "placed": System.out.println("In progress");
    case "dispatched": System.out.println("On its way"); break;
}
```

Prefer the arrow form. It cannot fall through, and it produces a value.

## 6. Methods and Parameter Passing

**Java is always pass-by-value.** For a reference type, the *reference* is copied — so the
method can change the object, but cannot make the caller's variable point somewhere else.

```java
static void addLine(List<OrderLine> lines) {
    lines.add(new OrderLine("KB-01", 1));   // caller sees this: same list object
}

static void replace(List<OrderLine> lines) {
    lines = new ArrayList<>();              // caller sees nothing: only the copy moved
}
```

Overloading gives one name several signatures. Choose parameter types that cannot be confused:

```java
// Wrong — call sites read as findOrder(5001, 3) and nobody can tell which is which
Order findOrder(long orderId, int customerId) { ... }

// Right — the types make the mistake impossible
Order findOrder(OrderId orderId, CustomerId customerId) { ... }
```

> **Tip.** Return `Optional<Order>` rather than `null` when a lookup may find nothing. It moves
> "this might be absent" from a comment into the signature.

## 7. Arrays

Fixed length, known at creation, and zero-indexed.

```java
int[] quantities = new int[3];        // {0, 0, 0}
int[] seeded = {2, 1, 4};

for (int i = 0; i < seeded.length; i++) {   // length is a field, not a method
    System.out.println(i + ": " + seeded[i]);
}
```

```java
// Wrong — <= reaches index 3 of a 3-element array
for (int i = 0; i <= seeded.length; i++) { ... }
// ArrayIndexOutOfBoundsException: Index 3 out of bounds for length 3
```

Arrays print unhelpfully and compare by identity:

```java
int[] a = {1, 2};
int[] b = {1, 2};
System.out.println(a);              // [I@6d06d69c
System.out.println(Arrays.toString(a));   // [1, 2]
a.equals(b)                         // false
Arrays.equals(a, b)                 // true
```

In application code prefer `List<T>` (unit 6). Arrays remain useful for primitives and for
`main(String[] args)`.

## 8. Worked Example — A Command-Line Utility

Reads a CSV of order lines and reports the total, which is the shape of the lab.

```java
package com.fsa.orderdesk.tools;

import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

public final class LineTotals {

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.err.println("usage: LineTotals <file.csv>");
            System.exit(2);                 // non-zero: a script can detect the failure
        }
        List<String> lines = Files.readAllLines(Path.of(args[0]));
        System.out.println("Total: " + total(lines));
    }

    // Package-private and pure, so it is testable without a file.
    static BigDecimal total(List<String> csvLines) {
        BigDecimal sum = BigDecimal.ZERO;
        for (String line : csvLines.subList(1, csvLines.size())) {   // skip the header
            String[] parts = line.split(",", -1);                    // -1 keeps empty trailing fields
            if (parts.length < 3) {
                throw new IllegalArgumentException("malformed line: " + line);
            }
            BigDecimal unitPrice = new BigDecimal(parts[2].trim());
            int quantity = Integer.parseInt(parts[1].trim());
            sum = sum.add(unitPrice.multiply(BigDecimal.valueOf(quantity)));
        }
        return sum;
    }
}
```

Two decisions worth naming. `split(",", -1)` keeps trailing empty fields, so a line ending in a
comma does not silently lose a column. And `total` takes a `List<String>` rather than a path,
so the test needs no file.

## 9. Common Problems

### `NullPointerException: Cannot invoke "String.length()" because "sku" is null`

Java 21 names the expression that was null. Read it: it tells you *which* reference, not just
the line.

### `String` comparison works in tests and fails in production

`==` on literals is true by interning; on strings built at runtime it is false. Use `equals`.

### `NumberFormatException: For input string: " 3"`

`Integer.parseInt` does not trim. Call `.trim()`, or `.strip()` for Unicode whitespace.

### The value did not change after calling the method

You reassigned the parameter instead of mutating the object. Java is pass-by-value.

### `ArrayIndexOutOfBoundsException: Index 3 out of bounds for length 3`

A loop using `<=`, or an off-by-one in an index calculation.

### `incompatible types: possible lossy conversion from double to int`

An implicit narrowing. Say what you mean with a cast, or fix the type.

## 10. Practical Guidelines

- Use `BigDecimal` for money, constructed from a `String`.
- Compare with `equals`, and put the non-null side on the left.
- Prefer the enhanced `for` and the arrow `switch`.
- Make helper methods package-private and pure so they can be tested directly.
- Return `Optional<T>` instead of `null` for lookups.
- Use `String.join` or `StringBuilder` for accumulation, never `+=` in a loop.

## 11. Knowledge Check

1. `a == b` is true for two `String` literals but false for two strings read from a file. Why?
2. A method takes a `List` and calls `list.add(...)`; another reassigns the parameter. Which
   change does the caller see, and why?
3. Why is `new BigDecimal("0.1")` correct and `new BigDecimal(0.1)` wrong?
4. Give a `split` call that loses data, and the fix.
5. What does `Integer count = null; int c = count;` throw, and at which step?

## 12. Further Reading

- [The Java Tutorials: Language Basics](https://docs.oracle.com/javase/tutorial/java/nutsandbolts/)
- [`java.lang.String` API](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/String.html)
- [`java.math.BigDecimal` API](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/math/BigDecimal.html)

---

Next: [Lab 02 — A command-line utility from a specification](lab-02.md), then [Object-Oriented Design & Modern Java Types](objects-and-modern-types.md).
