# Lab 01 — Bootstrap the API and wire it with configuration

**Duration:** 120 min

## Objectives

By the end of this lab you will be able to:

- Create a Spring Boot project and start it against a real database.
- Use constructor injection and typed configuration properties.
- Vary configuration by profile without changing code.

## Before you start

- You have read [Spring Boot IoC, Beans, Dependency Injection & Configuration](ioc-beans-and-configuration.md).
- Your OrderDesk database from Database Foundations rebuilds cleanly.
- Docker is available.

## Steps

1. **Generate the project** from Spring Initializr with `web`, `data-jpa`, `validation`,
   `security`, `postgresql` and `actuator`. Java 21, Maven, package `com.fsa.orderdesk`.

2. **Start it and read the failure.** Run `./mvnw spring-boot:run` before configuring anything.
   Paste the datasource error into `docs/startup.md` and explain in one sentence what Spring was
   telling you.

3. **Configure the datasource** in `application.yml`. The password comes from `${DB_PASSWORD}`
   with **no default**. Set `ddl-auto: validate` — the schema stays owned by your SQL scripts.

4. **Prove validate works.** Rename a column in one entity, start up, and paste the
   `SchemaManagementException` into `docs/startup.md`. Fix it.

5. **Add typed configuration.** Create a `ShippingProperties` record bound to
   `orderdesk.shipping` with `freeThreshold` and `standardCost`, annotated `@Validated` with
   `@NotNull @Positive` on both.

6. **Prove the validation fires at startup.** Set `free-threshold: -1`, start, and record the
   failure. Explain why failing here is better than failing on the first order.

7. **Write a service** taking `ShippingProperties` and a `Clock` through its constructor, with
   `final` fields and no `@Autowired`.

8. **Show why field injection is worse.** In `docs/injection.md`, write the same class with
   field injection and list three concrete consequences — one of which must be demonstrated by
   a plain JUnit test that cannot construct it.

9. **Add profiles.** `local` turns `show-sql` on; `docker` points the datasource at the `db`
   host. Show both starting, and record the command for each.

10. **Break the wiring deliberately.** Remove `@Service` from one class, start up, and paste the
    "required a bean of type" error with the Action section into `docs/startup.md`.

## Acceptance

- [ ] The application starts and connects to PostgreSQL.
- [ ] No password appears in any tracked file; `${DB_PASSWORD}` has no default.
- [ ] `ddl-auto: validate`, with a recorded validation failure it caught.
- [ ] `ShippingProperties` is a `@Validated` record, and a bad value fails startup.
- [ ] All beans use constructor injection with `final` fields and no `@Autowired`.
- [ ] `docs/injection.md` demonstrates one field-injection consequence with a test.
- [ ] Two profiles exist and both start, with the commands recorded.
- [ ] `docs/startup.md` contains three real error messages, each explained.

---

Next: [REST Controllers, DTOs & HTTP Semantics](rest-controllers-and-dtos.md).
