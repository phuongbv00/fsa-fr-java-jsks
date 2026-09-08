# Java Core, JDBC & JPA/Hibernate — Appendix

> See [Java Core, JDBC & JPA/Hibernate Persistence — Study Guide](index.md).

## 1. Syllabus Map

| # | Syllabus item | Covered in |
|---|---|---|
| 1 | Development Environment & the Java Toolchain | [Development Environment & the Java Toolchain](toolchain-and-build.md) |
| 2 | Java Syntax, Types & Methods | [Java Syntax, Types & Methods](language-fundamentals.md) |
| 3 | Object-Oriented Design & Modern Java Types | [Object-Oriented Design & Modern Java Types](objects-and-modern-types.md) |
| 4 | Interfaces, Polymorphism & Composition | [Interfaces, Polymorphism & Composition](interfaces-and-polymorphism.md) |
| 5 | Exceptions & Unit Testing | [Exceptions & Unit Testing](exceptions-and-testing.md) |
| 6 | Collections, Generics, Lambdas & Streams | [Collections, Generics, Lambdas & Streams](collections-and-streams.md) |
| 7 | JDBC & Repository Pattern | [JDBC & the Repository Pattern](jdbc-and-repositories.md) |
| 8 | JPA/Hibernate Mapping | [JPA & Hibernate Mapping](jpa-and-hibernate.md) |
| 9 | Persistence Performance | [Persistence Performance](persistence-performance.md) |

## 2. Objective Coverage

| Code | Objective | Taught in | Practised in |
|---|---|---|---|
| JCF-K1 | Toolchain and language fundamentals | Notes 01–04 | Labs 01–04 |
| JCF-K2 | Robust data processing | Notes 05, 06 | Labs 05, 06 |
| JCF-K3 | Persistence implementation | Notes 07, 08 | Labs 07, 08 |
| JCF-K4 | Persistence diagnosis | Notes 07, 09 | Labs 07, 09 |

## 3. Maven Quick Reference

```bash
mvn clean package          # the everyday loop
mvn test                   # tests only
mvn -DskipTests package    # skip tests: for a hurry, never for a commit
mvn dependency:tree        # what is on the classpath, and why
mvn -e clean package       # with a stack trace
mvn -X clean package       # with debug output, naming the failing plugin
```

| Scope | Compile | Test | Packaged |
|---|:--:|:--:|:--:|
| `compile` | yes | yes | yes |
| `provided` | yes | yes | no |
| `runtime` | no | yes | yes |
| `test` | no | yes | no |

## 4. Choosing a Type

| Concept | Use | Because |
|---|---|---|
| Money | `BigDecimal` from a `String` | Binary floats cannot represent decimal fractions |
| An instant | `Instant` / `timestamptz` | Unambiguous across zones |
| A calendar day | `LocalDate` | A birthday is not an instant |
| A closed set | `enum` | The values are known and checkable |
| A value with no identity | `record` | Generated `equals`, `hashCode`, accessors |
| Something with a lifecycle | `class` | Identity and mutable state |
| A possibly-absent result | `Optional<T>` | Absence in the signature, not in a comment |

## 5. JDBC Checklist

- [ ] Pooled `DataSource`, never `DriverManager`
- [ ] Every value through `?`; identifiers validated against a closed set
- [ ] Every resource in try-with-resources
- [ ] Columns read by name
- [ ] Nullable numerics read with `getObject(name, Long.class)`
- [ ] One connection per transaction; `rollback()` in `catch`
- [ ] Auto-commit restored in `finally`
- [ ] `SQLException` translated with its cause attached

## 6. JPA Checklist

- [ ] Protected no-arg constructor on every entity
- [ ] Enums by `EnumType.STRING`, or a converter when the column has its own vocabulary — never `ORDINAL`
- [ ] Associations `LAZY`
- [ ] Owning side set through a helper that keeps both sides consistent
- [ ] `hbm2ddl.auto=validate`
- [ ] `show_sql` on while developing
- [ ] Lookups return `Optional`, not `getSingleResult`
- [ ] N+1 fixed at the query, with a query-count test

## 7. Reading a Stack Trace

1. The last `Caused by:` is the real fault.
2. The topmost frame in your own package below it is where to look.
3. Framework frames are the path, not the cause.
4. `... 8 more` means those frames repeat the enclosing trace; nothing is hidden.

## 8. Primary Sources

- [JDK 17 documentation](https://docs.oracle.com/en/java/javase/17/)
- [Maven: Build Lifecycle](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html)
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [The Java Tutorials: JDBC Basics](https://docs.oracle.com/javase/tutorial/jdbc/basics/)
- [Jakarta Persistence 3.2](https://jakarta.ee/specifications/persistence/3.2/)
- [Hibernate ORM User Guide](https://docs.jboss.org/hibernate/orm/7.1/userguide/html_single/Hibernate_User_Guide.html)

---

Back to [Java Core, JDBC & JPA/Hibernate Persistence — Study Guide](index.md).
