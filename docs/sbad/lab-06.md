# Lab 06 — Authentication with JWT

**Duration:** 180 min

## Objectives

By the end of this lab you will be able to:

- Store users with correctly hashed passwords.
- Issue and verify a signed JWT.
- Configure a stateless security chain that denies by default.

## Before you start

- You have read [Authentication with Spring Security & JWT](authentication-and-jwt.md).
- Lab 05 is complete.

## Steps

1. **Add the tables.** `app_user` with a unique email, a `password_hash` and a nullable
   `customer_id` foreign key to `customer`, plus `app_user_role`. Seed at least one customer
   login (linked to customer 42 from the seed data), one staff member and one admin.

2. **Hash correctly.** Configure `BCryptPasswordEncoder` with a cost of at least 10. Write a test
   showing the same password produces two different hashes and both `matches`.

3. **Show why a fast hash is wrong.** In `docs/security.md`, time BCrypt against SHA-256 for
   100 hashes and record both (BCrypt at cost 12 takes about a quarter of a second *each* —
   that is the point, and it is why this is 100 and not 10 000). Extrapolate to a leaked table
   of a million hashes and write the two numbers down.

4. **Implement `UserDetailsService`** loading from the database into your own `AppUserDetails`
   that carries `userId` and `customerId`, with the same vague message for an unknown user as
   for a bad password.

5. **Implement `JwtService`** with issue and verify. The secret comes from `${JWT_SECRET}` with
   no default and is validated as at least 32 bytes.

6. **Set an expiry.** 30 minutes. Write a test that issues a token with a 1-second TTL, waits,
   and asserts verification fails.

7. **Implement the filter** reading `Authorization: Bearer`, verifying, and populating the
   security context. It must always call `chain.doFilter`.

8. **Configure the chain.** Stateless, CSRF disabled with a comment saying why that is safe
   here, an `HttpStatusEntryPoint(UNAUTHORIZED)` so a missing token is a 401 and not a 403,
   `/api/auth/login` permitted, everything else authenticated. Expose the `AuthenticationManager`
   as a bean.

9. **Implement `POST /api/auth/login`** returning a token, and one generic 401 for every
   failure, mapped in the unit 5 advice. Add `GET /api/auth/me` returning email, `customerId`
   and roles for the caller — the React module depends on it.

10. **Prove the negatives.** Record in `docs/security.md` the status for: no token; a malformed
    token; an expired token; a token signed with a different secret; a valid token. Then show
    the claims decoded at jwt.io and confirm nothing secret is in them.

11. **Prove deny-by-default.** Add a new endpoint with no rule and show it returns 401 without
    any change to the security configuration.

## Acceptance

- [ ] Passwords are BCrypt-hashed; no plaintext or fast hash anywhere.
- [ ] A test shows two different hashes for one password, both matching.
- [ ] `docs/security.md` records the BCrypt-versus-SHA-256 timing.
- [ ] Unknown user and wrong password are indistinguishable in the response.
- [ ] The JWT secret comes from the environment and is length-validated at startup.
- [ ] A test proves an expired token is rejected.
- [ ] The chain is stateless, ends with `anyRequest().authenticated()`, and answers a missing
      token with 401.
- [ ] `GET /api/auth/me` returns the caller's email, `customerId` and roles.
- [ ] Five token scenarios are recorded with their statuses.
- [ ] A new endpoint with no rule is protected automatically.
- [ ] No secret appears in any tracked file.

---

Next: [Authorization, CORS & OpenAPI](authorization-cors-and-openapi.md).
