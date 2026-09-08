# Containerization, Configuration & Observability

> Objectives: SBAD-K4 · Session 9 · Spring Boot 3.3, Docker 24 · See [Spring Boot API Development — Study Guide](index.md).

## 1. Objectives

After this unit, learners can:

- Build a container image for a Spring Boot application.
- Run the application and its database together with Compose.
- Externalize every environment-specific value, including secrets.
- Expose health and metrics with Actuator, and restrict what is public.
- Produce logs that can be read when something goes wrong.

## 2. Why a Container

"It works on my machine" is a statement about your machine. An image carries the JDK, the
application and its configuration defaults, so the thing that ran in testing is the thing that
runs in production.

```dockerfile
# Dockerfile — multi-stage: build with Maven, ship without it.
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /build

# Copy the descriptor first. Dependencies re-download only when the pom changes,
# not on every source edit — this is the difference between a 10s and a 3min build.
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw -B dependency:go-offline

COPY src/ src/
RUN ./mvnw -B clean package -DskipTests

FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

# Never run as root: a container escape then owns the host user.
RUN addgroup -S app && adduser -S app -G app
USER app

COPY --from=build /build/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

```dockerignore
target/
.git/
*.md
.env
```

```bash
docker build -t orderdesk-api:1.0 .
docker run --rm -p 8080:8080 -e DB_PASSWORD=secret orderdesk-api:1.0
```

The JRE runtime stage matters: a JDK image is roughly three times the size and ships a compiler
you do not need in production.

## 3. Compose

```yaml
# compose.yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: orderdesk
      POSTGRES_USER: orderdesk
      POSTGRES_PASSWORD: ${DB_PASSWORD:?DB_PASSWORD is required}
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./sql/schema.sql:/docker-entrypoint-initdb.d/01-schema.sql:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U orderdesk -d orderdesk"]
      interval: 5s
      timeout: 3s
      retries: 10

  api:
    build: .
    depends_on:
      db:
        condition: service_healthy      # wait for ready, not merely started
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://db:5432/orderdesk
      SPRING_DATASOURCE_USERNAME: orderdesk
      SPRING_DATASOURCE_PASSWORD: ${DB_PASSWORD}
      JWT_SECRET: ${JWT_SECRET:?JWT_SECRET is required}
      SPRING_PROFILES_ACTIVE: docker
    ports:
      - "8080:8080"

volumes:
  pgdata:
```

```bash
export DB_PASSWORD=... JWT_SECRET=...     # or a .env file, gitignored
docker compose up --build
docker compose logs -f api
docker compose down -v                     # -v also drops the data volume
```

Two details that cause most Compose problems. The database host is `db`, the **service name** —
`localhost` inside the api container is the api container. And `condition: service_healthy` is
what stops the application starting before PostgreSQL accepts connections; `depends_on` alone
only orders the start.

> **Note.** `${DB_PASSWORD:?...}` fails immediately with that message if the variable is unset.
> Better than a default, which would silently ship a known password.

## 4. Configuration Precedence

Spring Boot reads configuration from many places. Later sources win:

```text
1. application.yml packaged in the jar        (defaults, no secrets)
2. application-<profile>.yml                  (per environment)
3. Environment variables                      (secrets, per deployment)
4. Command-line arguments                     (overrides, debugging)
```

Any property maps to an environment variable by uppercasing and replacing dots with underscores:

```text
spring.datasource.url      ->  SPRING_DATASOURCE_URL
orderdesk.jwt.secret       ->  ORDERDESK_JWT_SECRET
```

That mapping is why the Compose file needs no image rebuild to change the database URL.

```yaml
# Wrong — a secret in a file that is committed
orderdesk:
  jwt:
    secret: aVeryLongSecretValueThatIsNowInGitForever

# Right
orderdesk:
  jwt:
    secret: ${JWT_SECRET}
```

## 5. Actuator

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus     # never "*"
  endpoint:
    health:
      show-details: when-authorized                 # never "always"
      probes:
        enabled: true
```

```bash
curl localhost:8080/actuator/health
```

```json
{"status":"UP"}
```

```json
{
  "status": "UP",
  "components": {
    "db":   {"status": "UP", "details": {"database": "PostgreSQL", "validationQuery": "isValid()"}},
    "diskSpace": {"status": "UP"},
    "ping": {"status": "UP"}
  }
}
```

The second body is what an authorized caller sees. Unauthenticated callers must get the first —
the details name your database engine and version, which is reconnaissance.

```yaml
# Wrong — exposes heapdump, env, threaddump, mappings to anyone who asks.
# /actuator/env alone can leak configuration values.
management.endpoints.web.exposure.include: "*"
```

Liveness and readiness probes let an orchestrator restart or withhold traffic correctly:

```text
/actuator/health/liveness    is the process alive?      restart if not
/actuator/health/readiness   can it serve traffic?      withhold traffic if not
```

A custom check for something the application genuinely depends on:

```java
@Component
public class PaymentGatewayHealthIndicator implements HealthIndicator {

    private final PaymentGateway gateway;

    public PaymentGatewayHealthIndicator(PaymentGateway gateway) { this.gateway = gateway; }

    @Override
    public Health health() {
        try {
            return gateway.ping()
                    ? Health.up().build()
                    : Health.down().withDetail("reason", "ping returned false").build();
        } catch (Exception e) {
            return Health.down(e).build();
        }
    }
}
```

## 6. Logs You Can Read

```yaml
logging:
  level:
    root: INFO
    com.fsa.orderdesk: DEBUG
    org.hibernate.SQL: DEBUG          # local only
  pattern:
    console: "%d{HH:mm:ss} %-5level [%X{requestId}] %logger{36} - %msg%n"
```

```java
// Wrong — no context, and string concatenation runs even when DEBUG is off
log.debug("order " + orderId + " cancelled by " + userId);

// Right — placeholders are resolved only if the level is enabled
log.debug("order {} cancelled by user {}", orderId, userId);
```

A request id in the MDC ties every line of one request together:

```java
@Component
public class RequestIdFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        String requestId = Optional.ofNullable(request.getHeader("X-Request-Id"))
                                   .orElseGet(() -> UUID.randomUUID().toString());
        MDC.put("requestId", requestId);
        try {
            response.setHeader("X-Request-Id", requestId);
            chain.doFilter(request, response);
        } finally {
            MDC.clear();      // the thread is pooled: not clearing leaks the id to the next request
        }
    }
}
```

```java
// Never log any of these
log.info("login for {} with password {}", email, password);
log.debug("issued token {}", jwt);
log.info("card {}", cardNumber);
```

## 7. Worked Example — Startup to Health

```bash
docker compose up --build -d

# 1. The database is accepting connections
docker compose exec db pg_isready -U orderdesk

# 2. The application reports UP
curl -s localhost:8080/actuator/health | jq .

# 3. An unauthenticated call is rejected — security survived containerization
curl -s -o /dev/null -w '%{http_code}\n' localhost:8080/api/orders     # 401

# 4. A real flow works end to end
TOKEN=$(curl -s -X POST localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"mai@example.com","password":"correct-horse"}' | jq -r .accessToken)
curl -s localhost:8080/api/orders -H "Authorization: Bearer $TOKEN" | jq '.totalElements'

# 5. Nothing secret is in the image
docker history orderdesk-api:1.0 --no-trunc | grep -i -E "password|secret" || echo "clean"
```

Step 5 is worth keeping in the routine. A secret passed as a build argument is baked into an
image layer and stays readable to anyone who can pull the image.

## 8. Common Problems

### `Connection refused` from the api container to the database

The URL says `localhost`. Inside a container that is the container. Use the service name, `db`.

### The application starts before the database is ready

`depends_on` without `condition: service_healthy`.

### The image is 700 MB

Building on a JDK base rather than copying the jar into a JRE runtime stage.

### Every build re-downloads dependencies

`COPY src/` happens before `dependency:go-offline`, invalidating the cache. Copy the pom first.

### `/actuator/env` exposes configuration

`exposure.include: "*"`. Name only the endpoints you need.

### Health says UP while the database is down

A custom indicator that catches everything and returns UP, or the datasource check disabled.

### Logs interleave and cannot be followed

No request id. Add the MDC filter.

## 9. Practical Guidelines

- Multi-stage build; run as a non-root user; ship a JRE, not a JDK.
- Copy the pom and resolve dependencies before copying source.
- Secrets come from the environment, and are never build arguments.
- `depends_on` with a health condition, always.
- Expose only the Actuator endpoints you need; `show-details: when-authorized`.
- Log with placeholders, never with concatenation, and never log a credential.

## 10. Knowledge Check

1. Why does the api container reach the database at `db` rather than `localhost`?
2. What breaks if `COPY src/` comes before dependency resolution?
3. Why is `management.endpoints.web.exposure.include: "*"` dangerous? Name one endpoint and what
   it leaks.
4. Why must `MDC.clear()` be in a `finally`?
5. A secret is passed with `--build-arg`. Why is that unsafe, and what should you do instead?

## 11. Further Reading

- [Spring Boot: Container Images](https://docs.spring.io/spring-boot/reference/packaging/container-images/index.html)
- [Spring Boot: Actuator](https://docs.spring.io/spring-boot/reference/actuator/index.html)
- [Docker Compose specification](https://docs.docker.com/compose/compose-file/)

---

Next: [Lab 09 — Containerize, configure and observe](lab-09.md), then [Spring Boot API Development — Appendix](appendix.md).
