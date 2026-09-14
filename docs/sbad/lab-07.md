# Lab 07 — Authorization, ownership, CORS and a published contract

**Duration:** 150 min

## Objectives

By the end of this lab you will be able to:

- Restrict endpoints by role and enforce ownership.
- Configure CORS deliberately and explain its limits.
- Publish an accurate OpenAPI contract.

## Before you start

- You have read [Authorization, CORS & OpenAPI](authorization-cors-and-openapi.md).
- Lab 06 is complete, with customer, staff and admin users seeded.

## Steps

1. **Add role rules.** Products are readable by anyone; writing them is `ADMIN`; cancelling any
   order is `STAFF` or `ADMIN`; everything else is authenticated.

2. **Demonstrate matcher order.** Put a broad `/api/**` rule before the admin rule, show a
   customer reaching an admin endpoint, and record it. Reorder and show 403.

3. **Find the IDOR.** Log in as customer A and fetch an order belonging to customer B by id.
   Record that it succeeds — this is the vulnerability.

4. **Fix it.** Take the identity from `@AuthenticationPrincipal`, never from a parameter. Scope
   the list endpoint to the caller and check ownership on the read endpoint.

5. **Return 404, not 403,** for another customer's order. Explain the reasoning in
   `docs/authz.md`.

6. **Remove the client-supplied identity.** If any endpoint takes `customerId` as a parameter to
   decide whose data to return, remove it and show the diff.

7. **Add method security.** `@EnableMethodSecurity` plus one `@PreAuthorize` expressing a rule
   the URL cannot — staff, or the owner.

8. **Configure CORS** with an explicit origin list, allowed methods and headers. Add
   `.cors(Customizer.withDefaults())` to the chain.

9. **Show what CORS does and does not do.** Record a browser fetch from a disallowed origin
   failing, and the same request via `curl` succeeding. Explain the difference in `docs/authz.md`.

10. **Publish the contract.** Add springdoc, configure the bearer scheme, and annotate every
    endpoint with its success **and** failure responses. Permit `/v3/api-docs/**` and
    `/swagger-ui/**`, and restrict them outside `local`.

11. **Test the matrix.** A table test over four roles × six endpoints asserting the expected
    status for each cell.

## Acceptance

- [ ] Role rules are ordered specific to general and end with `anyRequest().authenticated()`.
- [ ] The matcher-order demonstration is recorded, before and after.
- [ ] The IDOR is recorded as reproduced, then fixed.
- [ ] Identity comes only from the token; no endpoint takes a caller-supplied `customerId`.
- [ ] Another customer's order returns 404, with the reasoning documented.
- [ ] At least one `@PreAuthorize` expresses a rule a URL cannot.
- [ ] CORS lists origins explicitly; no `*` with credentials.
- [ ] `docs/authz.md` shows the browser-blocked and curl-allowed comparison.
- [ ] OpenAPI documents the bearer scheme and every endpoint's failure responses.
- [ ] A role-by-endpoint matrix test passes.

---

Next: [Testing Spring Applications](testing-spring-applications.md).
