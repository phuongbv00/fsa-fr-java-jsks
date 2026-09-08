# Async JavaScript & Strict TypeScript

> Objectives: FEF-K3 · Session 3 · TypeScript 5.6 · See [Frontend Foundations — Study Guide](index.md).

## 1. Objectives

After this unit, learners can:

- Use promises and `async`/`await`, and handle rejection correctly.
- Call an HTTP API with `fetch`, checking status rather than assuming success.
- Model an API contract with TypeScript types and interfaces.
- Implement typed data access with explicit loading, empty, success and error states.
- Read a TypeScript error and fix the cause rather than silencing it.

## 2. Promises and `async`/`await`

A promise is a value that will exist later, or a reason it will not.

```javascript
// A chain
fetchOrders().then(orders => render(orders)).catch(e => showError(e));

// The same thing, readable
try {
    const orders = await fetchOrders();
    render(orders);
} catch (e) {
    showError(e);
}
```

`await` only pauses the surrounding `async` function; the browser stays responsive.

Sequential when each step needs the previous one; parallel when they are independent:

```javascript
// Wrong — three round trips in series, for no reason
const orders   = await fetchOrders();
const products = await fetchProducts();
const customer = await fetchCustomer(42);

// Right — issued together, awaited together
const [orders, products, customer] = await Promise.all([
    fetchOrders(), fetchProducts(), fetchCustomer(42),
]);
```

`Promise.all` rejects as soon as any one does. When you want every result whatever happens, use
`Promise.allSettled`.

```javascript
// Wrong — an async function returns a promise; this logs "Promise { <pending> }"
const orders = fetchOrders();
console.log(orders.length);

// Wrong — forEach does not await, so this runs before anything finishes
orders.forEach(async (o) => { await cancelOrder(o.id); });

// Right
for (const o of orders) { await cancelOrder(o.id); }
// or, in parallel
await Promise.all(orders.map(o => cancelOrder(o.id)));
```

## 3. `fetch`

The trap that catches everyone: **`fetch` does not reject on 4xx or 5xx.** A 404 is a
successfully delivered response.

```javascript
// Wrong — a 401 or a 500 sails straight through and json() throws something confusing
const response = await fetch('/api/orders');
return await response.json();

// Right
const response = await fetch('/api/orders');
if (!response.ok) {
    throw new ApiError(response.status, await readError(response));
}
return await response.json();
```

```javascript
export class ApiError extends Error {
    constructor(status, message) {
        super(message);
        this.name = 'ApiError';
        this.status = status;
    }
}

async function readError(response) {
    try {
        // The ApiError contract from Spring Boot API Development.
        const body = await response.json();
        return body.message ?? response.statusText;
    } catch {
        return response.statusText;
    }
}
```

A typed request with a token and a timeout:

```javascript
export async function request(path, options = {}) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 10_000);

    try {
        const response = await fetch(path, {
            ...options,
            signal: controller.signal,
            headers: {
                'Content-Type': 'application/json',
                ...(token ? { Authorization: `Bearer ${token}` } : {}),
                ...options.headers,
            },
        });
        if (!response.ok) throw new ApiError(response.status, await readError(response));
        return response.status === 204 ? null : await response.json();
    } catch (e) {
        if (e.name === 'AbortError') throw new ApiError(0, 'The request timed out');
        throw e;
    } finally {
        clearTimeout(timeout);
    }
}
```

The `204` check matters: `response.json()` on an empty body throws, and a successful cancel
returns 204.

> **Note.** A CORS failure surfaces as a `TypeError: Failed to fetch` with no status. If you see
> that and the Network tab shows the request was made, the fix is in the API's CORS
> configuration, not here.

## 4. TypeScript: Modelling the Contract

```typescript
// src/api/types.ts

export type OrderStatus = 'PLACED' | 'PICKING' | 'DISPATCHED' | 'DELIVERED' | 'CANCELLED';

export interface OrderLine {
    sku: string;
    quantity: number;
    unitPrice: number;
}

export interface Order {
    id: number;
    customerId: number;
    placedAt: string;          // ISO-8601; not a Date until we parse it
    status: OrderStatus;
    total: number;
    lines: OrderLine[];
}

export interface Page<T> {
    content: T[];
    totalElements: number;
    totalPages: number;
    number: number;
    size: number;
}

// The error contract the API actually returns.
export interface ApiErrorBody {
    timestamp: string;
    status: number;
    message: string;
    path: string;
    fieldErrors: { field: string; message: string; rejectedValue: unknown }[];
}
```

A union type is the payoff:

```typescript
// Wrong — every typo compiles, and fails at runtime
status: string;

// Right — 'DISPATHCED' is a compile error, and the editor completes the values
status: OrderStatus;
```

```typescript
function label(status: OrderStatus): string {
    switch (status) {
        case 'PLACED':
        case 'PICKING':    return 'In progress';
        case 'DISPATCHED': return 'On its way';
        case 'DELIVERED':  return 'Delivered';
        case 'CANCELLED':  return 'Cancelled';
    }
    // Exhaustive: adding a status makes this stop compiling, which is the point.
}
```

## 5. Strictness

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

`strict` is what makes the type system worth having. `any` opts out of it entirely:

```typescript
// Wrong — no checking at all beyond this point
const orders: any = await request('/api/orders');
orders.contnet.forEach(...);        // compiles; fails at runtime

// Right — unknown forces you to narrow before use
const data: unknown = await request('/api/orders');
if (isOrderPage(data)) {
    data.content.forEach(...);
}
```

```typescript
// A type guard: a runtime check the compiler understands
export function isOrderPage(value: unknown): value is Page<Order> {
    return typeof value === 'object' && value !== null
        && Array.isArray((value as Page<Order>).content);
}
```

Handling absence honestly:

```typescript
// Wrong — the non-null assertion is a promise to the compiler you cannot keep
const row = document.querySelector('#order-rows')!;

// Right
const row = document.querySelector('#order-rows');
if (!row) throw new Error('#order-rows is missing from the page');
```

TypeScript is **structural**: a value fits a type if it has the right shape, whatever it is
called. And types vanish at runtime — they check your code, they do not validate the server's
response, which is why `isOrderPage` exists.

## 6. Worked Example — Typed Data Access with Four States

```typescript
// src/api/orders.ts
import type { Order, Page } from './types';
import { request } from './client';

export interface OrderQuery {
    status?: string;
    page?: number;
    size?: number;
}

export async function fetchOrders(query: OrderQuery = {}): Promise<Page<Order>> {
    const params = new URLSearchParams();
    if (query.status) params.set('status', query.status);
    params.set('page', String(query.page ?? 0));
    params.set('size', String(query.size ?? 20));
    return request<Page<Order>>(`/api/orders?${params}`);
}

export async function cancelOrder(orderId: number): Promise<void> {
    await request<null>(`/api/orders/${orderId}/cancellation`, { method: 'POST' });
}
```

```typescript
// src/ui/state.ts — the four states, in the type system
export type ViewState<T> =
    | { kind: 'loading' }
    | { kind: 'empty' }
    | { kind: 'success'; data: T }
    | { kind: 'error'; message: string; status?: number };
```

```typescript
// src/ui/orders-screen.ts
import { fetchOrders, cancelOrder } from '../api/orders';
import { ApiError } from '../api/client';
import type { Order, Page } from '../api/types';
import type { ViewState } from './state';

let state: ViewState<Page<Order>> = { kind: 'loading' };

function render(): void {
    // Exhaustive: add a state to ViewState and this stops compiling.
    switch (state.kind) {
        case 'loading': showMessage('Loading orders…');            break;
        case 'empty':   showMessage('No orders match these filters.'); break;
        case 'error':   showMessage(state.message, 'error');       break;
        case 'success': showRows(state.data.content);              break;
    }
}

export async function load(query: OrderQuery = {}): Promise<void> {
    state = { kind: 'loading' };
    render();
    try {
        const page = await fetchOrders(query);
        state = page.content.length === 0
            ? { kind: 'empty' }
            : { kind: 'success', data: page };
    } catch (e) {
        state = e instanceof ApiError
            ? { kind: 'error', message: messageFor(e), status: e.status }
            : { kind: 'error', message: 'Something went wrong. Please try again.' };
    }
    render();
}

function messageFor(e: ApiError): string {
    // Turn a status into something a user can act on.
    if (e.status === 401) return 'Your session has expired. Please sign in again.';
    if (e.status === 403) return 'You do not have permission to view these orders.';
    if (e.status === 0)   return 'The request timed out. Check your connection.';
    return e.message;
}
```

The discriminated union is doing real work: forgetting a state is a compile error, not a blank
screen.

## 7. Common Problems

### `TypeError: Failed to fetch`

A network failure or CORS. Check the Network tab: if the request was made and blocked, it is
CORS, and the fix is server-side.

### A 404 was treated as success

`response.ok` was not checked.

### `Unexpected end of JSON input`

`response.json()` on an empty body — usually a 204.

### `Property 'contnet' does not exist on type 'Page<Order>'`

TypeScript catching a typo. Fix the typo; do not cast to `any`.

### `Object is possibly 'null'`

`querySelector` can return null. Check it rather than adding `!`.

### The loop finished before the requests did

`forEach` with an `async` callback. Use `for...of` with `await`, or `Promise.all`.

### Everything is `any` and nothing is checked

`strict` is off, or the code is full of casts. Turn it on and fix the errors it finds.

## 8. Practical Guidelines

- Check `response.ok` on every `fetch`, and read the error body.
- Model the API contract as types, and use unions for closed sets.
- `strict: true`; use `unknown` and a type guard rather than `any`.
- Never use `!` to silence a null check — handle the null.
- Model view state as a discriminated union so a missing state cannot compile.
- Parallelise independent requests with `Promise.all`.

## 9. Knowledge Check

1. Why does `fetch` not reject on a 404, and what must you write instead?
2. What does `response.json()` do on a 204, and how do you avoid it?
3. Why is `status: OrderStatus` better than `status: string`? Give an error each one catches or
   misses.
4. What is a type guard, and why is one needed if TypeScript already types the response?
5. Give the four members of `ViewState` and say what a user sees if you forget the third.

## 10. Further Reading

- [MDN: Using the Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch)
- [MDN: Using promises](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [TypeScript: Narrowing](https://www.typescriptlang.org/docs/handbook/2/narrowing.html)

---

Next: [Lab 03 — Typed access to the real API](lab-03.md), then [Frontend Foundations — Appendix](appendix.md).
