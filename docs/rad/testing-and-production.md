# Testing, Error Boundaries & the Production Build

> Objectives: RAD-K3 · Session 6 · Vitest 2, Testing Library 16, Vite 5 · See [React Application Development — Study Guide](index.md).

## 1. Objectives

After this unit, learners can:

- Write component tests that assert what a user sees, not implementation details.
- Query by accessible role and label, and say why that matters.
- Mock the network and test loading, empty, success and error paths.
- Catch render failures with an error boundary.
- Configure the API URL by environment and produce a production build.

## 2. Test What a User Experiences

```tsx
// src/features/orders/OrdersTable.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

test('shows a row per order and cancels the one that was clicked', async () => {
    const onCancel = vi.fn();
    render(<OrdersTable orders={[order(5001, 'PLACED'), order(5002, 'DISPATCHED')]}
                        onCancel={onCancel} />);

    expect(screen.getAllByRole('row')).toHaveLength(3);          // header + 2
    expect(screen.getByText('5001')).toBeInTheDocument();

    await userEvent.click(screen.getAllByRole('button', { name: /cancel/i })[0]);
    expect(onCancel).toHaveBeenCalledWith(5001);
});

test('a dispatched order cannot be cancelled', () => {
    render(<OrdersTable orders={[order(5002, 'DISPATCHED')]} onCancel={vi.fn()} />);
    expect(screen.getByRole('button', { name: /cancel/i })).toBeDisabled();
});

test('says so when there is nothing to show', () => {
    render(<OrdersTable orders={[]} onCancel={vi.fn()} />);
    expect(screen.getByText(/no orders match/i)).toBeInTheDocument();
});
```

Query the way a user finds things:

| Prefer | Over | Because |
|---|---|---|
| `getByRole('button', { name })` | `container.querySelector('.btn')` | It is how the control is actually exposed |
| `getByLabelText('Status')` | `getById('status')` | It fails if the label is missing |
| `getByText(/no orders/i)` | snapshot | The assertion says what it checks |

```tsx
// Wrong — passes even if the button is unreachable and unlabelled
const button = container.querySelector('.cancel-btn');

// Right — fails if it is not a real, named button, which is a bug worth failing on
const button = screen.getByRole('button', { name: /cancel/i });
```

That is the hidden benefit: role-based queries fail when the accessibility work from Frontend
Foundations was skipped.

```tsx
// Wrong — asserting on state is asserting on implementation
expect(component.state.loading).toBe(false);

// Right — assert on what is rendered
expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
```

## 3. Async and the Network

```tsx
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';

const server = setupServer(
    http.get('*/api/orders', () => HttpResponse.json({ content: [order(5001, 'PLACED')] })),
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('shows the orders once they arrive', async () => {
    render(<OrdersPage />, { wrapper: AllProviders });

    expect(screen.getByRole('status')).toHaveTextContent(/loading/i);
    // findBy* waits; getBy* would fail before the response arrives.
    expect(await screen.findByText('5001')).toBeInTheDocument();
});

test('shows an error when the API fails', async () => {
    server.use(http.get('*/api/orders', () => new HttpResponse(null, { status: 500 })));

    render(<OrdersPage />, { wrapper: AllProviders });
    expect(await screen.findByRole('alert')).toHaveTextContent(/went wrong/i);
});

test('shows the empty state', async () => {
    server.use(http.get('*/api/orders', () => HttpResponse.json({ content: [] })));

    render(<OrdersPage />, { wrapper: AllProviders });
    expect(await screen.findByText(/no orders match/i)).toBeInTheDocument();
});
```

A wrapper supplies the router and the auth context that components under test expect:

```tsx
export function AllProviders({ children }: { children: React.ReactNode }) {
    return (
        <MemoryRouter>
            <AuthProvider>{children}</AuthProvider>
        </MemoryRouter>
    );
}
```

| Query | Waits | Fails when absent |
|---|:--:|:--:|
| `getBy*` | no | yes |
| `queryBy*` | no | no — returns null, for asserting absence |
| `findBy*` | yes | yes |

## 4. Error Boundaries

An uncaught error during render unmounts the whole tree — the user gets a blank white page. A
boundary catches it and shows something.

```tsx
export class ErrorBoundary extends React.Component<Props, State> {
    state: State = { error: null };

    static getDerivedStateFromError(error: Error): State {
        return { error };
    }

    componentDidCatch(error: Error, info: React.ErrorInfo) {
        console.error('render failed', error, info.componentStack);
    }

    render() {
        if (this.state.error) {
            return (
                <div role="alert">
                    <h2>Something went wrong</h2>
                    <p>Try reloading. If it keeps happening, tell your trainer.</p>
                    <button onClick={() => this.setState({ error: null })}>Try again</button>
                </div>
            );
        }
        return this.props.children;
    }
}
```

```tsx
<ErrorBoundary>
    <RouterProvider router={router} />
</ErrorBoundary>
```

A boundary catches errors thrown **during render** in the tree below it. It does not catch errors
in event handlers, in `setTimeout`, or in async code — those need `try`/`catch` where they happen.

## 5. Environment Configuration

```bash
# .env.development — committed; no secrets
VITE_API_URL=http://localhost:8080

# .env.production — committed
VITE_API_URL=https://api.orderdesk.example

# .env.local — gitignored, overrides the others
```

```tsx
const baseUrl = import.meta.env.VITE_API_URL;
```

Only variables prefixed `VITE_` reach the client, which is a safety rail rather than a naming
convention.

```bash
# Wrong. This is bundled into JavaScript the browser downloads.
VITE_DB_PASSWORD=secret
VITE_JWT_SECRET=secret
```

**Anything in the front-end bundle is public.** There is no such thing as a client-side secret;
`view-source` is all it takes.

## 6. The Production Build

```bash
npm run build         # type-check, bundle, minify, hash filenames -> dist/
npm run preview       # serve dist/ locally, to test the real artifact
```

```text
dist/index.html                   0.46 kB │ gzip:  0.30 kB
dist/assets/index-C4f9Kk2p.css   12.84 kB │ gzip:  3.11 kB
dist/assets/index-DkP2mQ8x.js   187.42 kB │ gzip: 59.88 kB
```

The hashed filenames are what let the server cache assets forever and still ship an update: a
change means a new name.

A single-page application needs the server to serve `index.html` for unknown paths, or a reload
on `/orders/5001` returns 404:

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

```bash
# Prove nothing secret was bundled
grep -r "password\|secret" dist/assets/*.js && echo "LEAK" || echo "clean"
```

> **Tip.** Always test `npm run preview`, not just `npm run dev`. The dev server is lenient about
> things the build is not, and the build is what ships.

## 7. Worked Example — A Full Test

```tsx
test('a customer signs in, sees their orders, and cancels one', async () => {
    server.use(
        http.post('*/api/auth/login', () => HttpResponse.json({ accessToken: 'test-token' })),
        http.get('*/api/auth/me', () =>
            HttpResponse.json({ email: 'mai@example.com', roles: ['ROLE_STAFF'] })),
        http.get('*/api/orders', () => HttpResponse.json({ content: [order(5001, 'PLACED')] })),
        http.post('*/api/orders/5001/cancellation', () => new HttpResponse(null, { status: 204 })),
    );

    render(<App />, { wrapper: MemoryRouter });

    await userEvent.type(screen.getByLabelText(/email/i), 'mai@example.com');
    await userEvent.type(screen.getByLabelText(/password/i), 'correct-horse');
    await userEvent.click(screen.getByRole('button', { name: /sign in/i }));

    expect(await screen.findByText('5001')).toBeInTheDocument();

    await userEvent.click(screen.getByRole('button', { name: /cancel/i }));
    expect(await screen.findByText(/cancelled/i)).toBeInTheDocument();
});
```

Every query is by label or role. If a form control loses its label, this test fails — which is
the point.

## 8. Common Problems

### `Unable to find an element with the role "button"`

It is a `div`. Fix the component, not the test.

### The assertion runs before the data arrives

`getBy*` where `findBy*` was needed.

### `useNavigate() may be used only in the context of a Router`

Wrap the render in `MemoryRouter`.

### `not wrapped in act(...)`

State updated outside React's knowledge. Use `findBy*` and `userEvent`, which handle it.

### A blank white page in production

An error during render with no boundary. Add one at the root.

### `import.meta.env.VITE_API_URL` is undefined

Missing the `VITE_` prefix, or the dev server was not restarted.

### `/orders/5001` 404s after deployment

No SPA fallback on the server.

## 9. Practical Guidelines

- Query by role and label; never by class or test id where a role exists.
- Assert on what is rendered, never on internal state.
- Mock at the network boundary, and test all four states.
- One error boundary at the root, and know what it does not catch.
- Only `VITE_` variables reach the client, and none of them may be secret.
- Test `npm run preview`, and configure the SPA fallback.

## 10. Knowledge Check

1. Why is `getByRole('button', { name })` better than a class selector? What bug does it catch?
2. Distinguish `getBy*`, `queryBy*` and `findBy*` and give a use for each.
3. Name two error kinds an error boundary does not catch.
4. Why must nothing secret be in a `VITE_` variable?
5. `/orders/5001` works in the app but 404s on reload after deployment. Why, and what fixes it?

## 11. Further Reading

- [Testing Library: Guiding Principles](https://testing-library.com/docs/guiding-principles)
- [Vitest guide](https://vitest.dev/guide/)
- [React: Error boundaries](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary)
- [Vite: Env Variables and Modes](https://vite.dev/guide/env-and-mode)

---

Next: [Lab 06 — Tests, an error boundary and a production build](lab-06.md), then [React Application Development — Appendix](appendix.md).
