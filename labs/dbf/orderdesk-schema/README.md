# OrderDesk — order schema

The OrderDesk **order** database: `customer`, `product`, `orders`, `order_line`, `shipment`,
`shipment_line`, `return_request`, `return_line` and `staff`. It is the worked example from
Database Foundations unit 2, and it is the database that Java Core, Spring Boot API Development
and the front-end modules all read and write.

The Database Foundations labs do **not** build this schema — they model a second slice of the
domain, stock and suppliers, so you design one schema yourself while reading another. This one
is supplied so every later module starts from the same rows.

```
schema.sql    the tables, keys and constraints — drops and recreates everything
seed.sql      a small fixed data set with explicit ids (order 5001 is always order 5001)
rebuild.sh    dropdb, createdb, schema.sql, seed.sql — run it whenever the data is in doubt
```

```bash
cp -r fsa-fr-java-jsks/labs/dbf/orderdesk-schema ~/orderdesk-schema
cd ~/orderdesk-schema
./rebuild.sh                  # needs psql, createdb and dropdb on the PATH, PostgreSQL 18
psql orderdesk -c "SELECT order_id, status FROM orders ORDER BY order_id;"
```

Two decisions in it are worth knowing before the Java modules:

- `orders.status` is stored **lower case** (`'placed'`, `'picking'`, …) and constrained by a
  `CHECK`. The Java `OrderStatus` enum carries the same values in `dbValue()`, and JPA maps
  through a converter — `EnumType.STRING` would write `PLACED` and be refused.
- `shipment.dispatched_at` is **nullable**: a parcel exists once it is packed and is dispatched
  later. "Has this order started shipping" is `EXISTS (... WHERE dispatched_at IS NOT NULL)`,
  not "does a shipment row exist".

The seed contains: customers 42 and 99; products `KB-01`, `MS-04`, `HP-07` and a discontinued
`CB-02`; orders 5001 (placed), 5002 (picking, one of two parcels dispatched), 5003 (delivered
and partly returned) and 5004 (cancelled); staff 1–3, of whom 2 is the refunds clerk.
