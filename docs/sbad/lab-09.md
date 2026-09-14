# Lab 09 — Containerize, configure and observe

**Duration:** 150 min

## Objectives

By the end of this lab you will be able to:

- Build a small, non-root container image for the application.
- Run the application and database together with Compose.
- Externalize configuration and secrets.
- Expose health and metrics without leaking internals.

## Before you start

- You have read [Containerization, Configuration & Observability](containerization-and-observability.md).
- Lab 08 is complete and the suite passes.
- Docker and Compose are available.

## Steps

1. **Write a multi-stage `Dockerfile`.** Build on a JDK image, run on a JRE image, as a non-root
   user. Resolve dependencies before copying source.

2. **Measure the layering.** Build; change one line of Java; rebuild. Record both times in
   `docs/deploy.md`. Then move `COPY src/` above dependency resolution, rebuild, and record how
   much worse it gets. Restore the good order.

3. **Measure the image.** Record the size. Then build a single-stage JDK version and record that
   size too, with the difference explained.

4. **Write `compose.yaml`** with the api and a PostgreSQL service, a named volume, an init script
   from your DBF `schema.sql`, and a healthcheck.

5. **Use the health condition.** Show `depends_on` without `service_healthy` failing on a cold
   start, then add the condition and show it succeeding. Record both.

6. **Externalize everything.** No URL, username, password or secret is baked into the image. Use
   `${VAR:?message}` for the required ones and show the failure when one is missing.

7. **Add Actuator.** Expose only `health`, `info` and `metrics`. Set
   `show-details: when-authorized`.

8. **Show the leak you avoided.** Temporarily set `exposure.include: "*"`, curl
   `/actuator/env`, and record one configuration value it exposes. Revert.

9. **Add a custom health indicator** for something the application genuinely depends on, and show
   the health endpoint reporting `DOWN` when you stop that dependency.

10. **Add a request id filter** putting an id into the MDC and echoing it in a response header.
    Show three log lines from one request sharing the id.

11. **Verify end to end.** Run the five-step check from the note — database ready, health UP,
    unauthenticated 401, an authenticated flow, and no secret in `docker history`. Capture the
    transcript.

## Acceptance

- [ ] The image is multi-stage, runs as non-root, and ships a JRE.
- [ ] Build times with and without correct layer ordering are recorded.
- [ ] Image sizes for the multi-stage and single-stage builds are recorded and explained.
- [ ] `compose up` starts both services from nothing on a clean machine.
- [ ] The `service_healthy` demonstration is recorded, before and after.
- [ ] No secret is in the image, the compose file, or any tracked file.
- [ ] Actuator exposes only the named endpoints; `show-details: when-authorized`.
- [ ] The `/actuator/env` leak is demonstrated and reverted.
- [ ] A custom health indicator reports `DOWN` when its dependency stops.
- [ ] Three log lines from one request share a request id, echoed in a header.
- [ ] The five-step verification transcript is captured.

---

Next: [Spring Boot API Development — Appendix](appendix.md).
