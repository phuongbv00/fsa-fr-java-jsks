# Forms, Validation & Mutations

> Session 4 · React 18 · See [React Application Development — Study Guide](index.md).

## 1. Objectives

By the end of this unit you will be able to:

- Build controlled inputs backed by typed form state.
- Validate on the client without duplicating the server's authority.
- Submit a mutation and handle its pending, success and failure states.
- Display server-side field errors next to the fields they belong to.
- Prevent double submission and keep the list in step after a change.

## 2. Controlled Inputs

An input is controlled when its value comes from state and every keystroke updates it.

```tsx
const [sku, setSku] = useState('');

<label htmlFor="sku">SKU</label>
<input id="sku" value={sku} onChange={(e) => setSku(e.target.value)} />
```

```tsx
// Wrong — value with no onChange. React holds it fixed and the field appears frozen.
<input value={sku} />

// Wrong — value={undefined} makes it uncontrolled, then controlled, and React warns
const [sku, setSku] = useState<string | undefined>();

// Right — always a string, from the first render
const [sku, setSku] = useState('');
```

For a form with several fields, one object beats one `useState` per field:

```tsx
interface OrderFormState {
    customerId: string;      // strings, because inputs produce strings
    lines: { sku: string; quantity: string }[];
}

const [form, setForm] = useState<OrderFormState>({
    customerId: '',
    lines: [{ sku: '', quantity: '1' }],
});

function setField<K extends keyof OrderFormState>(key: K, value: OrderFormState[K]) {
    setForm(prev => ({ ...prev, [key]: value }));
}
```

Keep form fields as strings and convert on submit. A number input that must hold an empty string
while the user clears it cannot be typed as `number`.

Updating one item of a list without mutating:

```tsx
function setLine(index: number, patch: Partial<OrderFormState['lines'][number]>) {
    setForm(prev => ({
        ...prev,
        lines: prev.lines.map((line, i) => (i === index ? { ...line, ...patch } : line)),
    }));
}
```

## 3. Client Validation

Client validation is for speed of feedback. **The server remains the authority** — it is the
only side an attacker cannot edit.

```tsx
type Errors = Partial<Record<string, string>>;

function validate(form: OrderFormState): Errors {
    const errors: Errors = {};

    if (!form.customerId.trim()) {
        errors.customerId = 'Customer is required';
    } else if (Number.isNaN(Number(form.customerId))) {
        errors.customerId = 'Customer must be a number';
    }
    if (form.lines.length === 0) {
        errors.lines = 'Add at least one line';
    }
    form.lines.forEach((line, i) => {
        if (!/^[A-Z]{2}-\d{2}$/.test(line.sku)) {
            errors[`lines[${i}].sku`] = 'SKU must look like KB-01';
        }
        const qty = Number(line.quantity);
        if (!Number.isInteger(qty) || qty < 1) {
            errors[`lines[${i}].quantity`] = 'Quantity must be a whole number of at least 1';
        }
    });
    return errors;
}
```

The error keys deliberately match the server's `fieldErrors[].field` paths from Spring Boot API
Development. That is what lets one piece of rendering code display both.

Show an error after the user has left the field, not while they are still typing it:

```tsx
const [touched, setTouched] = useState<Record<string, boolean>>({});

<input id="sku" value={line.sku}
       onChange={(e) => setLine(i, { sku: e.target.value })}
       onBlur={() => setTouched(t => ({ ...t, [`lines[${i}].sku`]: true }))}
       aria-invalid={Boolean(shownError)}
       aria-describedby={shownError ? `${fieldId}-error` : undefined} />
{shownError && <p id={`${fieldId}-error`} className="field-error">{shownError}</p>}
```

`aria-invalid` and `aria-describedby` are what make the error reach a screen reader user. A red
border alone reaches nobody who cannot see it.

## 4. Submitting

```tsx
type SubmitState =
    | { kind: 'idle' }
    | { kind: 'submitting' }
    | { kind: 'error'; message: string; fieldErrors: Errors }
    | { kind: 'success'; orderId: number };

const [submit, setSubmit] = useState<SubmitState>({ kind: 'idle' });

async function handleSubmit(event: React.FormEvent) {
    event.preventDefault();

    const clientErrors = validate(form);
    if (Object.keys(clientErrors).length > 0) {
        setSubmit({ kind: 'error', message: 'Please correct the errors below',
                    fieldErrors: clientErrors });
        setTouched(allTouched(form));         // reveal every error at once
        return;
    }

    setSubmit({ kind: 'submitting' });
    try {
        const created = await createOrder(toRequest(form));
        setSubmit({ kind: 'success', orderId: created.id });
        navigate(`/orders/${created.id}`, { replace: true });
    } catch (e) {
        if (e instanceof ApiError && e.status === 400 && e.body?.fieldErrors) {
            // Map the server's field paths onto the same keys the client uses.
            setSubmit({
                kind: 'error',
                message: e.body.message,
                fieldErrors: Object.fromEntries(
                    e.body.fieldErrors.map(f => [f.field, f.message])),
            });
        } else {
            setSubmit({ kind: 'error', message: messageFor(e), fieldErrors: {} });
        }
    }
}
```

```tsx
<button type="submit" disabled={submit.kind === 'submitting'}>
    {submit.kind === 'submitting' ? 'Placing order…' : 'Place order'}
</button>
```

Disabling while submitting is not cosmetic. Without it an impatient double click creates two
orders, and the second one is a support ticket.

## 5. Keeping the List in Step

After a mutation the list on screen is stale.

```tsx
// Wrong — the row still shows PLACED until a manual reload
await cancelOrder(orderId);

// Right — refetch the authoritative state
await cancelOrder(orderId);
reload();
```

```tsx
// Optimistic: update immediately, roll back on failure.
// Only worth it when failure is rare and the change is small.
async function handleCancel(orderId: number) {
    const previous = orders;
    setOrders(orders.map(o => (o.id === orderId ? { ...o, status: 'CANCELLED' } : o)));
    try {
        await cancelOrder(orderId);
    } catch (e) {
        setOrders(previous);                 // put it back
        setError(messageFor(e));
    }
}
```

The refetch is the safe default: it cannot leave the screen disagreeing with the server.

## 6. Worked Example

```tsx
export function NewOrderPage() {
    const navigate = useNavigate();
    const [form, setForm] = useState<OrderFormState>({
        customerId: '', lines: [{ sku: '', quantity: '1' }],
    });
    const [touched, setTouched] = useState<Record<string, boolean>>({});
    const [submit, setSubmit] = useState<SubmitState>({ kind: 'idle' });

    const clientErrors = validate(form);
    const serverErrors = submit.kind === 'error' ? submit.fieldErrors : {};
    const errors = { ...clientErrors, ...serverErrors };

    function errorFor(field: string): string | undefined {
        return touched[field] || submit.kind === 'error' ? errors[field] : undefined;
    }

    return (
        <form onSubmit={handleSubmit} noValidate>
            <h2>New order</h2>

            {submit.kind === 'error' && (
                <p role="alert" className="form-error">{submit.message}</p>
            )}

            <div className="field">
                <label htmlFor="customerId">Customer</label>
                <input id="customerId" value={form.customerId}
                       onChange={(e) => setField('customerId', e.target.value)}
                       onBlur={() => setTouched(t => ({ ...t, customerId: true }))}
                       aria-invalid={Boolean(errorFor('customerId'))}
                       aria-describedby={errorFor('customerId') ? 'customerId-error' : undefined} />
                {errorFor('customerId') && (
                    <p id="customerId-error" className="field-error">{errorFor('customerId')}</p>
                )}
            </div>

            {form.lines.map((line, i) => (
                <fieldset key={i}>
                    <legend>Line {i + 1}</legend>
                    {/* ...sku and quantity fields, same pattern... */}
                    <button type="button" onClick={() => removeLine(i)}
                            disabled={form.lines.length === 1}>
                        Remove
                    </button>
                </fieldset>
            ))}

            <button type="button" onClick={addLine}>Add line</button>
            <button type="submit" disabled={submit.kind === 'submitting'}>
                {submit.kind === 'submitting' ? 'Placing order…' : 'Place order'}
            </button>
        </form>
    );
}
```

`noValidate` turns off the browser's own bubbles so your messages are the only ones, and they
are the ones tied to `aria-describedby`.

> **Note.** `key={i}` on the line fieldsets is defensible here only because lines have no id
> until saved and the list is short. Give them a generated id the moment reordering is possible.

## 7. Common Problems

### The field will not accept typing

`value` with no `onChange`.

### `A component is changing an uncontrolled input to be controlled`

Initial state was `undefined`. Start with `''`.

### Two orders were created

The submit button was not disabled while in flight.

### Server validation errors do not appear

The field path keys do not match. Align the client's keys with the server's `fieldErrors[].field`.

### The list still shows the old status

No refetch after the mutation.

### Every keystroke re-renders the whole page

Form state lives too high. Move it into the form component.

### The error is visible but not announced

Missing `role="alert"`, or `aria-describedby` not pointing at the message.

## 8. Practical Guidelines

- Controlled inputs, initialised to `''`, holding strings until submit.
- Update state immutably; never edit an array in place.
- Validate on the client for speed, and let the server be the authority.
- Use the server's field paths as your error keys.
- Disable submit while in flight, and say so in the label.
- Wire `aria-invalid` and `aria-describedby`, and use `role="alert"` for the summary.
- Refetch after a mutation unless you have a reason to be optimistic.

## 9. Knowledge Check

1. Why must a controlled input start as `''` rather than `undefined`?
2. Client validation is present. Why is server validation still required?
3. Why should client error keys match `fieldErrors[].field` from the API?
4. What goes wrong without `disabled={submitting}`? Describe the user's experience.
5. Contrast refetching with an optimistic update, and give a case for each.

## 10. Further Reading

- [React: Reacting to Input with State](https://react.dev/learn/reacting-to-input-with-state)
- [MDN: Client-side form validation](https://developer.mozilla.org/en-US/docs/Learn/Forms/Form_validation)
- [WAI: Form instructions and errors](https://www.w3.org/WAI/tutorials/forms/notifications/)

---

Next: [Lab 04 — Forms, validation and mutations](lab-04.md), then [Authentication, Authorization & Shared State](auth-and-shared-state.md).
