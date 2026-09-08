# Lab 02 — REST endpoints with a DTO boundary

**Duration:** 150 min · **Objectives:** SBAD-K1

## Objectives

After this lab, learners can:

- Design resource URIs and choose correct methods and status codes.
- Keep entities out of the API with explicit request and response DTOs.
- Return a paginated, stably ordered list.

## Before you start

- You have read [REST Controllers, DTOs & HTTP Semantics](rest-controllers-and-dtos.md).
- Lab 01 is complete.

## Steps

1. **Design the URIs.** In `docs/api.md`, a table of the eight endpoints below: URI, method,
   success status, and the failure statuses each can return.

   List orders · read one · create · cancel · list an order's lines · list products · read a
   product · deactivate a product.

2. **Implement `OrderController` and `ProductController`.** Nothing but binding, delegation and
   status codes — no business rules.

3. **Write the DTOs.** Separate request and response records. A request must not expose `id`,
   `status` or any computed field.

4. **Demonstrate mass assignment.** Temporarily bind a request body straight to the entity, then
   `curl` a body setting `"status":"DELIVERED"` and record the result in `docs/api.md`. Restore
   the DTO version and show the same request being ignored.

5. **Return 201 correctly.** Creation returns `201` with a `Location` header and the created
   resource. Prove it with `curl -i` and paste the response line and headers.

6. **Return 204 correctly.** Cancellation returns `204` with no body.

7. **Paginate.** The list endpoint takes a `Pageable`, defaults to size 20 sorted by `placedAt`
   descending, and includes a unique tie-break.

8. **Prove the tie-break matters.** Seed 30 orders sharing one `placedAt`. Page through them
   without the tie-break, record a row appearing twice or not at all, then add the tie-break and
   show every row appearing exactly once.

9. **Prove no entity escapes.** Write a test asserting the JSON of an order contains no field
   that exists only on the entity, and that fetching an order with lines does not throw
   `LazyInitializationException`.

## Acceptance

- [ ] `docs/api.md` documents eight endpoints with success and failure statuses.
- [ ] Controllers contain no business rules.
- [ ] Request and response DTOs are separate; requests expose no server-owned field.
- [ ] The mass-assignment demonstration is recorded, and the fixed version ignores the field.
- [ ] Creation returns 201 with `Location`; cancellation returns 204 with no body.
- [ ] No endpoint returns 200 carrying an error.
- [ ] The pagination demonstration shows the duplicate row before the tie-break and none after.
- [ ] A test proves no entity is serialized and no lazy-loading error occurs.

---

Next: [Spring Data JPA](spring-data-jpa.md).
