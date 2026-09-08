# REST Controllers, DTOs & HTTP Semantics

> Session 2 · Spring Boot 3.3 · See [Spring Boot API Development — Study Guide](index.md).

## 1. Objectives

By the end of this unit you will be able to:

- Design resource URIs and choose the right HTTP method for an operation.
- Return the correct status code, including for creation and for failure.
- Bind path variables, query parameters and request bodies.
- Keep entities out of the API by mapping to DTOs at the controller boundary.
- Return a paginated list with a stable order.

## 2. Resources, Not Actions

A REST URI names a *thing*. The verb is the HTTP method.

```text
Wrong                               Right
POST /getOrder?id=5001              GET    /api/orders/5001
POST /createOrder                   POST   /api/orders
POST /cancelOrderById/5001          POST   /api/orders/5001/cancellation
GET  /orders/deleteAll              DELETE /api/orders
```

Nouns are plural, hierarchy shows containment, and a state change that is not a plain update
becomes a sub-resource:

```text
GET    /api/orders                  list
POST   /api/orders                  create
GET    /api/orders/5001             read one
PUT    /api/orders/5001             replace
PATCH  /api/orders/5001             partial update
DELETE /api/orders/5001             remove
GET    /api/orders/5001/lines       the lines of one order
POST   /api/orders/5001/cancellation cancel it
```

| Method | Safe | Idempotent | Body |
|---|:--:|:--:|---|
| `GET` | yes | yes | no |
| `POST` | no | no | yes |
| `PUT` | no | yes | yes |
| `PATCH` | no | no | yes |
| `DELETE` | no | yes | no |

Idempotent means calling it twice has the same effect as once. `PUT /orders/5001` twice leaves
one order; `POST /orders` twice creates two. That difference decides whether a client may
safely retry after a timeout.

## 3. Status Codes

Return the code that describes what happened. "200 with an error message in the body" is the
single most common mistake in this module.

| Code | Use for |
|---|---|
| `200 OK` | A successful read or update returning a body |
| `201 Created` | A resource was created — include a `Location` header |
| `204 No Content` | Success with nothing to return, typically `DELETE` |
| `400 Bad Request` | Malformed or invalid input |
| `401 Unauthorized` | Not authenticated, or a bad token |
| `403 Forbidden` | Authenticated, but not allowed |
| `404 Not Found` | No such resource |
| `409 Conflict` | The request conflicts with current state |
| `422 Unprocessable` | Syntactically fine, semantically invalid |
| `500 Server Error` | We broke. Never for a client mistake |

```java
// Wrong — the client must parse the body to discover it failed
@PostMapping("/api/orders")
public Map<String, Object> create(@RequestBody CreateOrderRequest req) {
    if (req.lines().isEmpty()) {
        return Map.of("success", false, "message", "no lines");   // 200 OK
    }
    ...
}

// Right
@PostMapping("/api/orders")
public ResponseEntity<OrderResponse> create(@Valid @RequestBody CreateOrderRequest req) {
    Order created = service.place(req.toCommand());
    return ResponseEntity
            .created(URI.create("/api/orders/" + created.id()))   // 201 + Location
            .body(OrderResponse.from(created));
}
```

## 4. Binding

```java
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderService service;

    public OrderController(OrderService service) {
        this.service = service;
    }

    @GetMapping("/{orderId}")
    public OrderResponse findOne(@PathVariable long orderId) {
        return service.findById(orderId)
                      .map(OrderResponse::from)
                      .orElseThrow(() -> new OrderNotFoundException(orderId));
    }

    @GetMapping
    public Page<OrderSummaryResponse> list(
            @RequestParam(required = false) OrderStatus status,
            @PageableDefault(size = 20, sort = "placedAt", direction = Sort.Direction.DESC)
            Pageable pageable) {
        return service.find(status, pageable).map(OrderSummaryResponse::from);
    }

    @PostMapping("/{orderId}/cancellation")
    public ResponseEntity<Void> cancel(@PathVariable long orderId) {
        service.cancel(orderId);
        return ResponseEntity.noContent().build();       // 204
    }
}
```

`orElseThrow` rather than returning `404` inline is deliberate: unit 5 turns that exception into
a consistent error body in one place, for every controller.

## 5. The DTO Boundary

**Entities must not cross the API boundary.** This is the rule this unit exists to establish.

```java
// Wrong — the entity is the API
@GetMapping("/{orderId}")
public Order findOne(@PathVariable long orderId) { ... }
```

Four things go wrong, all of them in production rather than in testing:

1. **The schema becomes the contract.** Rename a column and you have broken every client.
2. **Lazy loading explodes.** Serialization touches `order.getLines()` after the transaction
   closed — `LazyInitializationException`, from Java Core unit 9.
3. **Everything leaks.** A `passwordHash` or an internal cost field is serialized because it is
   a field.
4. **Input becomes unsafe.** Binding a request body straight onto an entity lets a client set
   `id` or `status` — mass assignment.

```java
// Right — explicit types for each direction
public record CreateOrderRequest(
        @NotNull Long customerId,
        @NotEmpty @Valid List<CreateOrderLineRequest> lines) {}

public record CreateOrderLineRequest(
        @NotBlank String sku,
        @Positive int quantity) {}

public record OrderResponse(
        long id,
        long customerId,
        Instant placedAt,
        String status,
        BigDecimal total,
        List<OrderLineResponse> lines) {

    public static OrderResponse from(Order order) {
        return new OrderResponse(
                order.id(), order.customerId(), order.placedAt(),
                order.status().name(), order.total().amount(),
                order.lines().stream().map(OrderLineResponse::from).toList());
    }
}
```

Separate request and response types even when they look alike. They diverge — a response gains
an id and a total, a request never should — and merging them is how `id` becomes settable.

> **Real-world use.** Mass assignment is a real vulnerability, not a style preference. If the
> request body binds to the entity, `{"status":"DELIVERED"}` marks an order delivered without
> shipping it.

## 6. Pagination

Never return an unbounded list. It works with the seed data and fails with a year of orders.

```java
@GetMapping
public Page<OrderSummaryResponse> list(
        @PageableDefault(size = 20, sort = "placedAt", direction = Sort.Direction.DESC)
        Pageable pageable) {
    return service.findAll(pageable).map(OrderSummaryResponse::from);
}
```

```bash
curl "localhost:8080/api/orders?page=0&size=20&sort=placedAt,desc"
```

```json
{
  "content": [ ... ],
  "totalElements": 1423,
  "totalPages": 72,
  "number": 0,
  "size": 20
}
```

A page needs a **total order**. Sorting only by `placedAt` when two orders share a timestamp
lets a row appear on both page 1 and page 2, or on neither.

```java
// Wrong — ties are ordered arbitrarily, and differently per query
Sort.by(Sort.Direction.DESC, "placedAt")

// Right — a unique tie-break makes paging stable
Sort.by(Sort.Direction.DESC, "placedAt").and(Sort.by("id"))
```

## 7. Worked Example — An Endpoint End to End

```java
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderService service;

    public OrderController(OrderService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<OrderResponse> create(@Valid @RequestBody CreateOrderRequest request) {
        Order created = service.place(request.customerId(), toLines(request));
        return ResponseEntity
                .created(URI.create("/api/orders/" + created.id()))
                .body(OrderResponse.from(created));
    }

    private static List<NewLine> toLines(CreateOrderRequest request) {
        return request.lines().stream()
                      .map(l -> new NewLine(new Sku(l.sku()), l.quantity()))
                      .toList();
    }
}
```

```bash
curl -i -X POST localhost:8080/api/orders \
  -H 'Content-Type: application/json' \
  -d '{"customerId": 42, "lines": [{"sku": "KB-01", "quantity": 2}]}'
```

```text
HTTP/1.1 201 Created
Location: /api/orders/5001
Content-Type: application/json

{"id":5001,"customerId":42,"placedAt":"2026-09-08T09:12:44Z","status":"PLACED",
 "total":300000,"lines":[{"sku":"KB-01","quantity":2,"unitPrice":150000}]}
```

Check the status line and the `Location` header, not just the body. `curl -i` is the habit
worth forming.

## 8. Common Problems

### `LazyInitializationException` during serialization

An entity is being returned from a controller. Map to a DTO inside the transaction.

### `404` for a URL that looks right

The controller is outside the scanned package tree, or `@RequestMapping` paths concatenate
differently from what you expect. The startup log lists every mapping.

### `415 Unsupported Media Type`

The request has no `Content-Type: application/json`.

### `400` with no explanation

Jackson cannot construct the DTO. Records work out of the box; a class needs a suitable
constructor or setters.

### The client can set fields it should not

The request DTO has fields that are not client input, or the entity is bound directly.

### A row appears on two pages

The sort has no unique tie-break.

## 9. Practical Guidelines

- URIs name plural resources; the method is the verb.
- Return `201` with `Location` on creation, `204` on a successful delete.
- Never return a `200` carrying an error.
- Separate request and response DTOs, and map explicitly.
- Paginate every list endpoint, with a unique tie-break in the sort.
- Throw a domain exception rather than building an error response in the controller.

## 10. Knowledge Check

1. Why is `POST /api/orders/5001/cancellation` preferred over `POST /cancelOrder?id=5001`?
2. `PUT` is idempotent and `POST` is not. What does that let a client do safely?
3. Give four distinct problems caused by returning a JPA entity from a controller.
4. Which status code, and why: creation succeeded; validation failed; the caller is
   authenticated but not permitted; the resource does not exist.
5. Why does a paginated query need a unique tie-break?

## 11. Further Reading

- [Spring: Web MVC](https://docs.spring.io/spring-framework/reference/web/webmvc.html)
- [MDN: HTTP response status codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
- [Spring Data: Paging and Sorting](https://docs.spring.io/spring-data/jpa/reference/repositories/query-methods-details.html)

---

Next: [Lab 02 — REST endpoints with a DTO boundary](lab-02.md), then [Spring Data JPA](spring-data-jpa.md).
