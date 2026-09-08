# React, JSX, Components & State

> Session 1 · React 18, TypeScript 5.6, Vite 5 · See [React Application Development — Study Guide](index.md).

## 1. Objectives

By the end of this unit you will be able to:

- Write a function component with typed props and compose components.
- Distinguish props from state and decide which a value should be.
- Compute derived values rather than storing them in state.
- Render a list with stable keys and explain what a key is for.
- Lift state to the closest common ancestor when two components need it.

## 2. A Component Is a Function of Its Inputs

```tsx
interface StatusBadgeProps {
    status: OrderStatus;
}

export function StatusBadge({ status }: StatusBadgeProps) {
    return <span className={`badge badge--${status.toLowerCase()}`}>{label(status)}</span>;
}
```

Given the same props it produces the same output. That is what makes a component testable and
predictable, and it is why props are read-only.

```tsx
// Wrong — mutating props. React will not re-render, and the caller is corrupted.
function OrderRow({ order }: { order: Order }) {
    order.status = 'CANCELLED';
    return <tr>...</tr>;
}

// Right — ask the owner of the data to change it
function OrderRow({ order, onCancel }: { order: Order; onCancel: (id: number) => void }) {
    return (
        <tr>
            <td>{order.id}</td>
            <td><button onClick={() => onCancel(order.id)}>Cancel</button></td>
        </tr>
    );
}
```

JSX is not HTML. `class` is `className`, `for` is `htmlFor`, attributes are camelCase, and every
expression goes in braces:

```tsx
<label htmlFor="status" className="field-label">Status</label>
<input id="status" value={status} onChange={e => setStatus(e.target.value)} />
```

A component returns one root. Use a fragment rather than an extra `div`:

```tsx
return (
    <>
        <h2>Orders</h2>
        <OrdersTable orders={orders} />
    </>
);
```

## 3. State

`useState` gives a component memory across renders.

```tsx
export function OrderFilters({ onApply }: { onApply: (q: OrderQuery) => void }) {
    const [status, setStatus] = useState<OrderStatus | ''>('');

    return (
        <form onSubmit={(e) => { e.preventDefault(); onApply({ status: status || undefined }); }}>
            <label htmlFor="status">Status</label>
            <select id="status" value={status}
                    onChange={(e) => setStatus(e.target.value as OrderStatus | '')}>
                <option value="">All</option>
                <option value="PLACED">Placed</option>
            </select>
            <button type="submit">Apply</button>
        </form>
    );
}
```

Two rules that cause most beginner bugs:

```tsx
// Wrong — mutating state. React compares by reference, sees no change, and does not re-render.
const [orders, setOrders] = useState<Order[]>([]);
orders.push(newOrder);
setOrders(orders);

// Right — a new array
setOrders([...orders, newOrder]);
setOrders(orders.filter(o => o.id !== id));
setOrders(orders.map(o => (o.id === id ? { ...o, status: 'CANCELLED' } : o)));
```

```tsx
// Wrong — both reads see the same `count`, so this adds one, not two
setCount(count + 1);
setCount(count + 1);

// Right — the updater form sees the latest value
setCount(c => c + 1);
setCount(c => c + 1);
```

State updates are asynchronous. Reading the variable straight after setting it gives the old
value — the new one arrives on the next render.

## 4. Derived State

If a value can be computed from what you already have, compute it. Do not store it.

```tsx
// Wrong — two sources of truth that will disagree
const [orders, setOrders] = useState<Order[]>([]);
const [total, setTotal] = useState(0);

useEffect(() => {
    setTotal(orders.reduce((sum, o) => sum + o.total, 0));   // an extra render, and a chance to drift
}, [orders]);

// Right — derived on every render, always correct
const total = orders.reduce((sum, o) => sum + o.total, 0);
```

The same applies to filtering:

```tsx
const [orders, setOrders] = useState<Order[]>([]);
const [query, setQuery] = useState('');

// Not state: a function of orders and query.
const visible = orders.filter(o => o.status.toLowerCase().includes(query.toLowerCase()));
```

> **Note.** Reach for `useMemo` only when a derived computation is genuinely expensive and you
> have measured it. Filtering a few hundred rows is not expensive.

## 5. Lists and Keys

```tsx
<tbody>
    {orders.map(order => (
        <OrderRow key={order.id} order={order} onCancel={handleCancel} />
    ))}
</tbody>
```

A key tells React which item is which between renders.

```tsx
// Wrong — the index changes when the list is sorted, filtered or an item is removed.
// React reuses the wrong DOM node, so input values and focus attach to the wrong row.
{orders.map((order, i) => <OrderRow key={i} order={order} />)}

// Right — a stable identity that belongs to the data
{orders.map(order => <OrderRow key={order.id} order={order} />)}
```

The failure is specific and worth seeing once: with index keys, delete the first row of a table
whose rows contain inputs, and the second row keeps the first row's typed text.

Conditional rendering:

```tsx
{orders.length === 0 && <p>No orders match these filters.</p>}
{loading ? <Spinner /> : <OrdersTable orders={orders} />}

// Wrong — when the array is empty this renders "0", because 0 is falsy but not false
{orders.length && <OrdersTable orders={orders} />}
```

## 6. Lifting State Up

When two components need the same value, it belongs in their closest common ancestor.

```tsx
export function OrdersPage() {
    // Owned here because both the filters and the table need it.
    const [query, setQuery] = useState<OrderQuery>({});
    const [orders, setOrders] = useState<Order[]>([]);

    return (
        <>
            <OrderFilters onApply={setQuery} />
            <p>{orders.length} orders</p>
            <OrdersTable orders={orders} onCancel={...} />
        </>
    );
}
```

Data flows down as props; changes flow up as callbacks. When you find yourself passing a prop
through four components that do not use it, that is the signal for context — unit 5.

## 7. Worked Example — The Orders Screen

```tsx
// src/features/orders/OrdersTable.tsx
interface OrdersTableProps {
    orders: Order[];
    onCancel: (orderId: number) => void;
}

export function OrdersTable({ orders, onCancel }: OrdersTableProps) {
    if (orders.length === 0) {
        return <p>No orders match these filters.</p>;
    }
    return (
        <div className="table-wrapper">
            <table>
                <caption>Orders matching the current filters</caption>
                <thead>
                    <tr>
                        <th scope="col">Order</th>
                        <th scope="col">Placed</th>
                        <th scope="col">Status</th>
                        <th scope="col">Total</th>
                        <th scope="col"><span className="sr-only">Actions</span></th>
                    </tr>
                </thead>
                <tbody>
                    {orders.map(order => (
                        <tr key={order.id}>
                            <td>{order.id}</td>
                            <td>{formatDate(order.placedAt)}</td>
                            <td><StatusBadge status={order.status} /></td>
                            <td>{formatMoney(order.total)}</td>
                            <td>
                                <button type="button"
                                        disabled={order.status !== 'PLACED'}
                                        onClick={() => onCancel(order.id)}>
                                    Cancel
                                </button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}
```

The semantic table, caption and scoped headers come straight from Frontend Foundations. React
did not make those unnecessary.

## 8. Common Problems

### The screen does not update after `setState`

State was mutated rather than replaced. Create a new array or object.

### Two updates in a row only apply once

Both read the same stale value. Use the updater form, `setX(prev => ...)`.

### Editing one row changes another

Index keys. Use a stable id.

### `Each child in a list should have a unique "key" prop`

A `map` with no key. It is a warning with real consequences.

### `0` appears on the page

`{array.length && <X />}`. Use a ternary or `length > 0 &&`.

### `Cannot update a component while rendering a different component`

`setState` called during render rather than in an event handler or an effect.

### `Objects are not valid as a React child`

Rendering an object. Render a field, or format it first.

## 9. Practical Guidelines

- Type every component's props with an interface; never `any`.
- Props are read-only; changes go up through callbacks.
- Never mutate state — always produce a new value.
- Use the updater form whenever the next value depends on the previous.
- Compute derived values; do not store them.
- Key lists by a stable id from the data, never by index.

## 10. Knowledge Check

1. When should a value be state, and when should it be derived? Give one of each from this page.
2. `setCount(count + 1)` twice adds one. Why, and what is the fix?
3. Describe a concrete bug caused by `key={index}`.
4. Why does `{orders.length && <Table/>}` render `0`, and what should you write?
5. Two sibling components need the same filter value. Where does it live, and how does each get it?

## 11. Further Reading

- [React: Describing the UI](https://react.dev/learn/describing-the-ui)
- [React: Adding Interactivity](https://react.dev/learn/adding-interactivity)
- [React: Rendering Lists](https://react.dev/learn/rendering-lists)

---

Next: [Lab 01 — Components, props and state](lab-01.md), then [Effects, Data Fetching & Custom Hooks](effects-and-data-fetching.md).
