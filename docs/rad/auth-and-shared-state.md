# Authentication, Authorization & Shared State

> Session 5 · React 18, React Router 6 · See [React Application Development — Study Guide](index.md).

## 1. Objectives

By the end of this unit you will be able to:

- Share state across a component tree with context, and say when not to.
- Hold session state and implement login and logout.
- Attach the token to every request in one place.
- Protect routes and redirect to login, returning the user afterwards.
- Handle expiry, and explain why the client cannot enforce authorization.

## 2. Context

Context passes a value to a whole subtree without threading props through components that do not
use it.

```tsx
// Wrong — token threaded through four components that do not use it
<AppLayout token={token}>
    <OrdersPage token={token}>
        <OrdersTable token={token}>
            <OrderRow token={token} />
```

```tsx
// src/auth/AuthContext.tsx
interface AuthContextValue {
    user: AuthUser | null;
    token: string | null;
    login: (email: string, password: string) => Promise<void>;
    logout: () => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function useAuth(): AuthContextValue {
    const context = useContext(AuthContext);
    // A clear message beats "cannot read properties of null" three files away.
    if (!context) throw new Error('useAuth must be used inside <AuthProvider>');
    return context;
}
```

> **Note.** Context is for genuinely global state — the session, a theme, a locale. Putting
> everything in context makes every consumer re-render whenever any part changes, and hides
> where data comes from.

## 3. The Provider

```tsx
export function AuthProvider({ children }: { children: React.ReactNode }) {
    const [token, setToken] = useState<string | null>(() => sessionStorage.getItem('token'));
    const [user, setUser] = useState<AuthUser | null>(null);

    useEffect(() => {
        if (!token) { setUser(null); return; }
        // Trust the server for identity; the token is only a credential.
        fetchMe(token).then(setUser).catch(() => { setToken(null); setUser(null); });
    }, [token]);

    useEffect(() => {
        token ? sessionStorage.setItem('token', token) : sessionStorage.removeItem('token');
    }, [token]);

    const login = useCallback(async (email: string, password: string) => {
        const { accessToken } = await postLogin(email, password);
        setToken(accessToken);
    }, []);

    const logout = useCallback(() => { setToken(null); setUser(null); }, []);

    // Memoised, or every consumer re-renders on every provider render.
    const value = useMemo(() => ({ user, token, login, logout }), [user, token, login, logout]);

    return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
```

Where to keep the token is a real trade-off, and neither answer is perfect:

| Store | Survives a reload | Readable by injected script |
|---|---|---|
| Memory only | no | no |
| `sessionStorage` | within the tab | yes |
| `localStorage` | indefinitely | yes |
| `HttpOnly` cookie | yes | **no** |

`sessionStorage` is this module's choice: better than `localStorage` because it dies with the
tab, and simple enough not to obscure the lesson. An `HttpOnly` cookie is the stronger answer
and needs server changes beyond this module's scope.

## 4. Attaching the Token

One place, not per call.

```tsx
// src/api/client.ts
let authToken: string | null = null;
export function setAuthToken(token: string | null) { authToken = token; }

export async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
    const response = await fetch(`${import.meta.env.VITE_API_URL}${path}`, {
        ...options,
        headers: {
            'Content-Type': 'application/json',
            ...(authToken ? { Authorization: `Bearer ${authToken}` } : {}),
            ...options.headers,
        },
    });
    if (!response.ok) throw new ApiError(response.status, await readError(response));
    return response.status === 204 ? (null as T) : await response.json();
}
```

```tsx
// Inside AuthProvider — keep the client in step with the context
useEffect(() => { setAuthToken(token); }, [token]);
```

```tsx
// Wrong — every call site must remember, and one will not
fetch('/api/orders', { headers: { Authorization: `Bearer ${token}` } });
```

## 5. Protected Routes

```tsx
export function RequireAuth() {
    const { token } = useAuth();
    const location = useLocation();

    if (!token) {
        // Remember where they were going, and do not push a history entry.
        return <Navigate to="/login" replace state={{ from: location }} />;
    }
    return <Outlet />;
}
```

```tsx
const router = createBrowserRouter([
    { path: '/login', element: <LoginPage /> },
    {
        element: <RequireAuth />,
        children: [
            {
                path: '/',
                element: <AppLayout />,
                children: [
                    { path: 'orders', element: <OrdersPage /> },
                    { path: 'orders/:orderId', element: <OrderDetailPage /> },
                ],
            },
        ],
    },
]);
```

```tsx
export function LoginPage() {
    const { login, token } = useAuth();
    const location = useLocation();
    const navigate = useNavigate();
    const from = (location.state as { from?: Location })?.from?.pathname ?? '/orders';

    useEffect(() => { if (token) navigate(from, { replace: true }); }, [token, from, navigate]);
    ...
}
```

Returning the user to `from` is what makes a session expiring mid-task tolerable: they log in
and land back where they were.

## 6. Expiry

A token expires and every request starts returning 401. Handle it once, centrally.

```tsx
export function useApiErrorHandler() {
    const { logout } = useAuth();
    const navigate = useNavigate();

    return useCallback((error: unknown) => {
        if (error instanceof ApiError && error.status === 401) {
            logout();
            navigate('/login', { replace: true });
            return 'Your session has expired. Please sign in again.';
        }
        return messageFor(error);
    }, [logout, navigate]);
}
```

## 7. What the Client Cannot Do

Hiding a button is a courtesy, not a control.

```tsx
// Useful — do not offer what will fail
{user?.roles.includes('ROLE_STAFF') && (
    <button onClick={() => cancelOrder(order.id)}>Cancel</button>
)}
```

```tsx
// Not security — anyone can call the endpoint directly
if (!user?.roles.includes('ROLE_ADMIN')) return <p>Not allowed</p>;
```

```bash
# The button is hidden. The endpoint is not.
curl -X POST localhost:8080/api/orders/5001/cancellation -H "Authorization: Bearer $TOKEN"
```

Authorization is enforced by the API — the rules from Spring Boot API Development unit 7. The
client hides what would fail; the server decides what is allowed. Both are needed, for different
reasons.

## 8. Worked Example

```tsx
export function AppLayout() {
    const { user, logout } = useAuth();

    return (
        <div className="layout">
            <header>
                <h1>OrderDesk</h1>
                <div className="user">
                    {user && (
                        <>
                            <span>{user.email}</span>
                            <button type="button" onClick={logout}>Sign out</button>
                        </>
                    )}
                </div>
            </header>

            <nav aria-label="Main">
                <ul>
                    <li><NavLink to="/orders">Orders</NavLink></li>
                    {user?.roles.includes('ROLE_ADMIN') && (
                        <li><NavLink to="/admin">Admin</NavLink></li>
                    )}
                </ul>
            </nav>

            <main><Outlet /></main>
        </div>
    );
}
```

## 9. Common Problems

### `useAuth must be used inside <AuthProvider>`

The component is outside the provider — often a test. Wrap it.

### Everything re-renders on every keystroke

The context value is a new object each render. Wrap it in `useMemo`.

### The user is logged out on every reload

The token is only in memory. Persist it, and restore it in the initial state.

### Login redirects to the wrong page

`state.from` not captured, or `replace` not used.

### 401s appear after some time and nothing happens

Expiry is not handled centrally. Add the handler.

### A hidden admin button is treated as security

It is not. The API must enforce it.

## 10. Practical Guidelines

- One `AuthProvider` at the root; access it only through `useAuth`.
- Memoise the context value.
- Attach the token in the API client, never at a call site.
- Guard routes with a layout route, redirecting with `replace` and remembering `from`.
- Handle 401 in one place: log out, redirect, explain.
- Hide what would fail; never rely on hiding for security.

## 11. Knowledge Check

1. What problem does context solve here, and what does overusing it cost?
2. Why must the context value be memoised?
3. Compare `sessionStorage`, `localStorage` and an `HttpOnly` cookie for the token.
4. Why capture `location.state.from`, and why redirect with `replace`?
5. A cancel button is hidden for customers. Why is the API check still required?

## 12. Further Reading

- [React: Passing Data Deeply with Context](https://react.dev/learn/passing-data-deeply-with-context)
- [React Router: Authentication](https://reactrouter.com/en/main/start/concepts#authentication)
- [OWASP: HTML5 Security — Local Storage](https://cheatsheetseries.owasp.org/cheatsheets/HTML5_Security_Cheat_Sheet.html)

---

Next: [Lab 05 — Session state and protected routes](lab-05.md), then [Testing, Error Boundaries & the Production Build](testing-and-production.md).
