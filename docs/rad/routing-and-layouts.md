# Routing & Shared Layouts

> Session 3 · React Router 7 · See [React Application Development — Study Guide](index.md).

## 1. Objectives

By the end of this unit you will be able to:

- Configure routes and render them inside a shared layout.
- Read route parameters and query strings in a typed way.
- Navigate programmatically and with links, preserving history correctly.
- Handle a not-found route and an unknown resource distinctly.
- Keep filter state in the URL so a screen can be shared and bookmarked.

## 2. Routes

```tsx
// src/routes.tsx — exported on its own so a test can build a memory router over it (unit 6)
export const routes = [
    {
        path: '/',
        element: <AppLayout />,
        errorElement: <RouteError />,
        children: [
            { index: true, element: <Navigate to="/orders" replace /> },
            { path: 'orders', element: <OrdersPage /> },
            { path: 'orders/:orderId', element: <OrderDetailPage /> },
            { path: 'products', element: <ProductsPage /> },
            { path: '*', element: <NotFoundPage /> },      // must be last
        ],
    },
    { path: '/login', element: <LoginPage /> },            // outside the layout: no nav
];

// src/main.tsx
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { routes } from './routes';

const router = createBrowserRouter(routes);
const root = document.getElementById('root');
if (!root) throw new Error('#root is missing from index.html');
createRoot(root).render(<RouterProvider router={router} />);
```

`path: '*'` last is what turns a mistyped URL into a page rather than a blank screen. Note that
`/login` sits outside `AppLayout`, because a signed-out user should not see the navigation.

## 3. Shared Layouts

A layout renders the chrome once and an `<Outlet />` where the child route goes.

```tsx
export function AppLayout() {
    return (
        <div className="layout">
            <header><h1>OrderDesk</h1></header>

            <nav aria-label="Main">
                <ul>
                    <li>
                        {/* NavLink knows whether it is active */}
                        <NavLink to="/orders"
                                 className={({ isActive }) => (isActive ? 'active' : undefined)}>
                            Orders
                        </NavLink>
                    </li>
                    <li><NavLink to="/products">Products</NavLink></li>
                </ul>
            </nav>

            <main>
                <Outlet />
            </main>

            <footer><p>FPT Software Academy</p></footer>
        </div>
    );
}
```

`NavLink` also sets `aria-current="page"` on the active link for you — the attribute from
Frontend Foundations, maintained by the router. Do not write it yourself:

```tsx
// Wrong — hard-coded, so every link claims to be the current page
<NavLink to="/orders" aria-current="page">Orders</NavLink>

// Right — NavLink adds and removes it as the route changes
<NavLink to="/orders">Orders</NavLink>
```

## 4. Links, Not Anchors

```tsx
// Wrong — a full page reload: the whole application restarts and state is lost
<a href="/orders/5001">Order 5001</a>

// Right — client-side navigation
<Link to={`/orders/${order.id}`}>Order {order.id}</Link>
```

Programmatic navigation, after an action:

```tsx
const navigate = useNavigate();

async function handleCreate(request: CreateOrderRequest) {
    const created = await createOrder(request);
    navigate(`/orders/${created.id}`);              // adds a history entry
    // navigate(`/orders/${created.id}`, { replace: true });  // replaces it
}
```

`replace` matters after a redirect: without it, the back button returns to the page you just
redirected away from, which redirects again — an inescapable loop.

## 5. Parameters

```tsx
// The route component validates; the hook is called by a child, so it is never called
// after an early return — hooks must run on every render, in the same order.
export function OrderDetailPage() {
    const { orderId } = useParams();        // always string | undefined

    // Validate at the boundary: the URL is user input.
    const id = Number(orderId);
    if (!orderId || !Number.isInteger(id) || id <= 0) {
        return <p role="alert">That is not a valid order number.</p>;
    }
    return <OrderDetail orderId={id} />;
}

function OrderDetail({ orderId }: { orderId: number }) {
    const { order, loading, error } = useOrder(orderId);    // unit 2's hook
    ...
}
```

```tsx
// Wrong — the hook runs on some renders and not others: "Rendered fewer hooks than expected"
if (!orderId) return <p role="alert">…</p>;
const { order } = useOrder(Number(orderId));
```

```tsx
// Wrong — orderId is a string; the API receives "5001" where a number was typed
const { order } = useOrder(orderId);
```

Query strings hold filter state, which makes a filtered screen shareable:

```tsx
export function OrdersPage() {
    const [searchParams, setSearchParams] = useSearchParams();
    const status = (searchParams.get('status') ?? '') as OrderStatus | '';

    const { orders, loading, error } = useOrders({ status: status || undefined });

    function apply(next: OrderStatus | '') {
        // Replace, not push: changing a filter should not fill the back history.
        setSearchParams(next ? { status: next } : {}, { replace: true });
    }
    ...
}
```

The URL is now the state. Reload, bookmark or paste it to a colleague and the same screen
appears — which a `useState` filter cannot do.

## 6. Two Different Not-Founds

They look similar and mean different things.

| Situation | Response |
|---|---|
| `/ordrs` — no such route | `path: '*'` renders `NotFoundPage` |
| `/orders/99999` — route exists, resource does not | The page renders its own "not found" |

```tsx
export function NotFoundPage() {
    return (
        <>
            <h2>Page not found</h2>
            <p>That address does not exist. <Link to="/orders">Go to orders</Link>.</p>
        </>
    );
}
```

```tsx
// Inside OrderDetailPage — a 404 from the API, not a routing miss
if (error?.status === 404) {
    return (
        <>
            <h2>Order {id} not found</h2>
            <p>It may have been removed. <Link to="/orders">Back to orders</Link>.</p>
        </>
    );
}
```

Every dead end offers a way out. A not-found page with no link is a trap.

## 7. Worked Example

```tsx
export function OrdersPage() {
    const [searchParams, setSearchParams] = useSearchParams();
    const status = (searchParams.get('status') ?? '') as OrderStatus | '';
    const page = Number(searchParams.get('page') ?? '0');

    const { orders, loading, error, reload } = useOrders({
        status: status || undefined,
        page: Number.isNaN(page) ? 0 : page,
    });

    function setFilter(next: OrderStatus | '') {
        const params = new URLSearchParams(searchParams);
        next ? params.set('status', next) : params.delete('status');
        params.delete('page');                  // a new filter starts at page 0
        setSearchParams(params, { replace: true });
    }

    return (
        <>
            <h2>Orders</h2>
            <OrderFilters value={status} onChange={setFilter} />

            {loading && <p role="status">Loading orders…</p>}
            {error && <p role="alert">{error} <button onClick={reload}>Retry</button></p>}
            {!loading && !error && orders.length === 0 && <p>No orders match these filters.</p>}
            {!loading && !error && orders.length > 0 && (
                <table>
                    <tbody>
                        {orders.map(order => (
                            <tr key={order.id}>
                                <td><Link to={`/orders/${order.id}`}>{order.id}</Link></td>
                                <td><StatusBadge status={order.status} /></td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            )}
        </>
    );
}
```

Deleting `page` when the filter changes prevents landing on page 5 of a two-page result — a
blank screen that looks like a bug.

## 8. Common Problems

### The whole app reloads on navigation

An `<a href>` where a `<Link to>` belongs.

### A mistyped URL shows a blank page

No `path: '*'` route, or it is not last.

### The back button loops

A redirect pushed instead of replacing. Use `{ replace: true }`.

### `orderId` is a string and the API rejects it

`useParams` always returns strings. Convert and validate.

### Filters reset on reload

The filter is in `useState`, not in the URL.

### `useNavigate() may be used only in the context of a Router`

The component is outside `RouterProvider` — often a test rendering it bare. Wrap it in
`MemoryRouter`.

## 9. Practical Guidelines

- One layout route with `<Outlet />`; keep `/login` outside it.
- `path: '*'` last, always, with a link out.
- `<Link>` and `<NavLink>` for navigation; `useNavigate` after actions.
- `{ replace: true }` for redirects and filter changes.
- Convert and validate route parameters at the boundary.
- Keep filter and page state in the URL.

## 10. Knowledge Check

1. What does `<Outlet />` do, and why is `/login` outside the layout route?
2. Why does an `<a href>` break a React application?
3. When is `{ replace: true }` required, and what happens without it?
4. Distinguish the two kinds of not-found, and say how each is handled.
5. Give two things that become possible by keeping filters in the URL.

## 11. Further Reading

- [React Router: Route configuration](https://reactrouter.com/en/main/route/route)
- [React Router: `useSearchParams`](https://reactrouter.com/en/main/hooks/use-search-params)
- [React Router: Navigating](https://reactrouter.com/en/main/components/link)

---

Next: [Lab 03 — Routing, layouts and URL state](lab-03.md), then [Forms, Validation & Mutations](forms-and-mutations.md).
