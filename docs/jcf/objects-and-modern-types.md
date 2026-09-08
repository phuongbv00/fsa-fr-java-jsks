# Object-Oriented Design & Modern Java Types

> Session 3 · JDK 17 · See [Java Core, JDBC & JPA/Hibernate Persistence — Study Guide](index.md).

## 1. Objectives

By the end of this unit you will be able to:

- Design a class with private state and a constructor that rejects invalid input.
- Choose composition over inheritance and say why in a given case.
- Implement `equals` and `hashCode` consistently, and predict what breaks when they are not.
- Use `record` for value types and `enum` for closed sets, and say when each is appropriate.
- Model a small domain so that an invalid instance cannot be constructed.

## 2. A Class Is an Invariant

An object is state plus the rules that keep it valid. The constructor's job is to make an
invalid instance impossible; the accessors' job is to keep it that way.

```java
package com.fsa.orderdesk.domain;

import java.math.BigDecimal;
import java.util.Objects;

public final class OrderLine {

    private final String sku;
    private final int quantity;
    private final BigDecimal unitPrice;

    public OrderLine(String sku, int quantity, BigDecimal unitPrice) {
        // Validate at the boundary. After this, every OrderLine in the system is valid.
        this.sku = Objects.requireNonNull(sku, "sku");
        if (sku.isBlank()) {
            throw new IllegalArgumentException("sku must not be blank");
        }
        if (quantity <= 0) {
            throw new IllegalArgumentException("quantity must be positive, was " + quantity);
        }
        this.unitPrice = Objects.requireNonNull(unitPrice, "unitPrice");
        if (unitPrice.signum() < 0) {
            throw new IllegalArgumentException("unitPrice must not be negative");
        }
        this.quantity = quantity;
    }

    public BigDecimal lineTotal() {
        return unitPrice.multiply(BigDecimal.valueOf(quantity));
    }

    public String sku() { return sku; }
    public int quantity() { return quantity; }
    public BigDecimal unitPrice() { return unitPrice; }
}
```

Notice what is absent: setters. Once constructed, an `OrderLine` cannot become invalid, so no
other code needs to re-check it. That is the whole return on validating in the constructor.

> **Note.** Include the offending value in the message — `"was " + quantity`. A message that
> only names the rule sends the reader back to a debugger.

### Encapsulation leaks

Returning a mutable field hands out the ability to change your state from outside:

```java
// Wrong — the caller can add lines to an order that thought it was finished
public List<OrderLine> lines() { return lines; }

// Right — the caller gets a view they cannot modify
public List<OrderLine> lines() { return List.copyOf(lines); }
```

## 3. Composition over Inheritance

Inheritance says "is a" and inherits everything, including decisions you did not make.
Composition says "has a" and takes only what it needs.

```java
// Wrong — a PriorityOrder is not a kind of Order with different data;
// it is an Order with different handling. Inheritance couples them forever.
public class PriorityOrder extends Order { ... }

// Right — the varying part is a collaborator
public final class Order {
    private final ShippingPolicy shipping;

    public Order(ShippingPolicy shipping) {
        this.shipping = Objects.requireNonNull(shipping);
    }

    public LocalDate promisedDate() {
        return shipping.promise(placedAt);
    }
}
```

The practical test: if you would have to override a method to *disable* it, inheritance is
wrong. A subclass that throws `UnsupportedOperationException` is telling you it is not really
that thing.

> **Real-world use.** The classic failure is `class Stack extends ArrayList`. A stack is not a
> list — but it inherits `add(int, E)`, so anyone can insert at the bottom.

## 4. `equals` and `hashCode`

Two rules, and everything follows from them:

1. Equal objects must have equal hash codes.
2. `hashCode` must not change while the object is in a hash collection.

Break the first and `HashSet` and `HashMap` stop working — quietly.

```java
// Wrong — equals without hashCode
public final class Sku {
    private final String value;

    @Override
    public boolean equals(Object o) {
        return o instanceof Sku other && value.equals(other.value);
    }
    // no hashCode: inherits identity hashing
}
```

```java
Set<Sku> seen = new HashSet<>();
seen.add(new Sku("KB-01"));
seen.contains(new Sku("KB-01"));   // false — different buckets, never compared
```

```java
// Right
@Override
public boolean equals(Object o) {
    return o instanceof Sku other && value.equals(other.value);
}

@Override
public int hashCode() {
    return Objects.hash(value);
}
```

The `instanceof` pattern above does three jobs at once: rejects `null`, checks the type, and
binds the cast variable.

> **Note.** Include only the fields that define identity. Two `OrderLine`s with the same SKU
> but different quantities are different lines; two `Sku`s with the same text are the same SKU.

## 5. Records

A `record` is the concise form of an immutable value type. The compiler generates the
constructor, accessors, `equals`, `hashCode` and `toString`.

```java
public record Sku(String value) {
    // Compact constructor: validation only, no assignment.
    public Sku {
        Objects.requireNonNull(value, "value");
        if (!value.matches("[A-Z]{2}-\\d{2}")) {
            throw new IllegalArgumentException("malformed sku: " + value);
        }
    }
}

public record Money(BigDecimal amount, String currency) {
    public Money {
        Objects.requireNonNull(amount, "amount");
        Objects.requireNonNull(currency, "currency");
    }

    public Money plus(Money other) {
        if (!currency.equals(other.currency)) {
            throw new IllegalArgumentException("cannot add " + currency + " to " + other.currency);
        }
        return new Money(amount.add(other.amount), currency);
    }
}
```

Use a record when the type *is* its data and never changes. Use a class when it has identity,
mutable state, or behaviour that dominates its data.

| Use a record for | Use a class for |
|---|---|
| `Sku`, `Money`, `DateRange` | `Order`, `OrderRepository` |
| A DTO carrying values across a boundary | Anything with a lifecycle |
| A method returning two values | Anything whose identity is not its data |

> **Tip.** Wrapping `String` in `Sku` and `BigDecimal` in `Money` looks like ceremony until the
> first time the compiler rejects `findOrder(customerId, orderId)` with the arguments swapped.

## 6. Enums

An enum is a closed set of values, known at compile time — the Java answer to the `CHECK
(status IN (...))` constraint from Database Foundations.

```java
public enum OrderStatus {
    PLACED("placed"),
    PICKING("picking"),
    DISPATCHED("dispatched"),
    DELIVERED("delivered"),
    CANCELLED("cancelled");

    private final String dbValue;

    OrderStatus(String dbValue) { this.dbValue = dbValue; }

    public String dbValue() { return dbValue; }

    public static OrderStatus fromDb(String value) {
        for (OrderStatus s : values()) {
            if (s.dbValue.equals(value)) return s;
        }
        throw new IllegalArgumentException("unknown status: " + value);
    }

    public boolean canBeCancelled() {
        return this == PLACED || this == PICKING;
    }
}
```

Two things worth copying. Behaviour like `canBeCancelled` lives on the enum, not scattered
through `if` statements. And `fromDb` fails loudly on an unknown value rather than returning
`null`, so a database change surfaces immediately.

A `switch` over an enum is checked for exhaustiveness:

```java
String message = switch (status) {
    case PLACED, PICKING -> "We are preparing your order";
    case DISPATCHED      -> "On its way";
    case DELIVERED       -> "Delivered";
    case CANCELLED       -> "Cancelled";
};      // add a constant later and this stops compiling — which is what you want
```

## 7. Worked Example — The OrderDesk Domain

```java
package com.fsa.orderdesk.domain;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public final class Order {

    private final long id;
    private final long customerId;
    private final Instant placedAt;
    private final List<OrderLine> lines = new ArrayList<>();
    private OrderStatus status;

    public Order(long id, long customerId, Instant placedAt) {
        if (customerId <= 0) {
            throw new IllegalArgumentException("customerId must be positive");
        }
        this.id = id;
        this.customerId = customerId;
        this.placedAt = Objects.requireNonNull(placedAt, "placedAt");
        this.status = OrderStatus.PLACED;
    }

    public void addLine(OrderLine line) {
        if (status != OrderStatus.PLACED) {
            throw new IllegalStateException("cannot add lines to an order that is " + status);
        }
        lines.add(Objects.requireNonNull(line, "line"));
    }

    public void cancel() {
        if (!status.canBeCancelled()) {
            throw new IllegalStateException("cannot cancel an order that is " + status);
        }
        status = OrderStatus.CANCELLED;
    }

    public Money total() {
        BigDecimal sum = lines.stream()
                              .map(OrderLine::lineTotal)
                              .reduce(BigDecimal.ZERO, BigDecimal::add);
        return new Money(sum, "VND");
    }

    public List<OrderLine> lines() { return List.copyOf(lines); }
    public OrderStatus status()    { return status; }
    public long id()               { return id; }

    // Identity is the database id, not the contents: two orders with identical
    // lines are still two different orders.
    @Override
    public boolean equals(Object o) {
        return o instanceof Order other && id == other.id;
    }

    @Override
    public int hashCode() { return Long.hashCode(id); }
}
```

The domain rules from Foundations are now compiler- and runtime-enforced: you cannot add a line
to a dispatched order, and you cannot cancel one.

## 8. Common Problems

### Objects vanish from a `HashSet`

`equals` overridden without `hashCode`, or a field used in `hashCode` mutated after insertion.

### `equals` is never called

The signature is wrong. `equals(Order o)` overloads rather than overrides — it must take
`Object`. Add `@Override` and the compiler will tell you.

### `ConcurrentModificationException`

Removing from a collection while iterating it. Use `Iterator.remove` or `removeIf`.

### A subclass throws `UnsupportedOperationException`

The inheritance relationship is wrong. Compose instead.

### The record has a setter

It cannot. That is the point — if the type needs to change, it is a class.

### `IllegalArgumentException` with no clue what was passed

Include the offending value in the message.

## 9. Practical Guidelines

- Validate in the constructor; then never re-check.
- Make fields `private final` by default, and the class `final` unless designed for extension.
- Return copies or unmodifiable views of mutable collections.
- Override `equals` and `hashCode` together, or neither.
- Use `record` for values, `enum` for closed sets, `class` for things with identity.
- Put behaviour on the enum rather than in `if` chains over it.

## 10. Knowledge Check

1. A class overrides `equals` but not `hashCode`. Give a concrete sequence of calls that
   produces a wrong answer.
2. When is inheritance the wrong tool? Give a test you can apply before choosing.
3. Why is `Money` a record and `Order` a class? What would break if they were swapped?
4. `lines()` returns the internal list directly. Give a call that corrupts the order.
5. `OrderStatus.fromDb` throws on an unknown value rather than returning null. Argue for that.

## 11. Further Reading

- [The Java Tutorials: Classes and Objects](https://docs.oracle.com/javase/tutorial/java/javaOO/)
- [JEP 395: Records](https://openjdk.org/jeps/395)
- [`Object.equals` contract](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/lang/Object.html#equals(java.lang.Object))

---

Next: [Lab 03 — Model the OrderDesk domain](lab-03.md), then [Interfaces, Polymorphism & Composition](interfaces-and-polymorphism.md).
