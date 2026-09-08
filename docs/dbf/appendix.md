# Database Foundations — Appendix

> See [Database Foundations — Study Guide](index.md).

## 1. Syllabus Map

Where each item of the topic outline is taught.

| # | Syllabus item | Covered in |
|---|---|---|
| 1 | Relational Modelling & Normalization | [Relational Modelling & Normalization](relational-modelling.md) |
| 2 | DDL, Constraints & Data Integrity | [DDL, Constraints & Data Integrity](ddl-and-constraints.md) |
| 3 | SQL Querying & Data Manipulation | [SQL Querying, Plans & Transactions](querying-plans-and-transactions.md#2-reading-and-changing-rows) |
| 4 | Joins, Grouping & Aggregation | [SQL Querying, Plans & Transactions](querying-plans-and-transactions.md#3-joins) |
| 5 | Indexes, Query Plans & Transactions | [SQL Querying, Plans & Transactions](querying-plans-and-transactions.md#6-query-plans-and-one-index) |
| 6 | Final Assessments | Issued separately |

## 2. Objective Coverage

| Code | Objective | Taught in | Practised in |
|---|---|---|---|
| DBF-K1 | Relational data modelling | Notes 01, 02 | Labs 01, 02 |
| DBF-K2 | SQL querying and data change | Note 03 | Lab 03 |
| DBF-K3 | Performance and transaction reasoning | Note 03 | Lab 03 |

## 3. SQL Quick Reference

Statement order, as written and as executed — the difference explains most surprises:

```text
Written:   SELECT → FROM → JOIN → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT
Executed:  FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
```

That is why a `SELECT` alias cannot be used in `WHERE` but can be used in `ORDER BY`, and why
`WHERE count(*)` is an error.

| Task | Statement |
|---|---|
| Rows with no match | `LEFT JOIN b ON … WHERE b.pk IS NULL` |
| Existence test | `WHERE EXISTS (SELECT 1 FROM … )` |
| Non-existence test | `WHERE NOT EXISTS (…)` — never `NOT IN` on a nullable column |
| Filter groups | `HAVING`, not `WHERE` |
| Count rows vs non-nulls | `count(*)` vs `count(col)` |
| Read back a generated key | `INSERT … RETURNING id` |
| Name a query step | `WITH step AS (…) SELECT …` |

## 4. Reading a Plan

| Line | Means | Usually do |
|---|---|---|
| `Seq Scan` with large `Rows Removed by Filter` | Read everything, kept little | Consider an index on the filtered column |
| `Index Scan` | Index found the rows | Nothing |
| `Nested Loop` with large `loops=` | Inner side ran many times | Index the join column |
| `actual rows` far from planner `rows` | Statistics are stale | `ANALYZE` |
| `Sort` with `external merge Disk` | Sorted on disk | Reduce the sorted set, or raise `work_mem` |

## 5. Environment Commands

```bash
createdb orderdesk                       # create
dropdb --if-exists orderdesk             # remove
psql orderdesk                           # interactive session
psql -v ON_ERROR_STOP=1 orderdesk -f schema.sql   # run a script, stop on first error
psql orderdesk -c "SELECT 1"             # one statement
```

Inside `psql`:

```text
\dt            list tables
\d orders      describe one table, with its constraints
\di            list indexes
\timing on     report execution time per statement
\x             expanded output, for wide rows
\q             quit
```

## 6. Primary Sources

- [PostgreSQL 16 documentation](https://www.postgresql.org/docs/16/index.html)
- [Data Definition](https://www.postgresql.org/docs/16/ddl.html)
- [Constraints](https://www.postgresql.org/docs/16/ddl-constraints.html)
- [Queries](https://www.postgresql.org/docs/16/queries.html)
- [Using EXPLAIN](https://www.postgresql.org/docs/16/using-explain.html)
- [Transaction Isolation](https://www.postgresql.org/docs/16/transaction-iso.html)
- [Mermaid ER diagrams](https://mermaid.js.org/syntax/entityRelationshipDiagram.html)

---

Back to [Database Foundations — Study Guide](index.md).
