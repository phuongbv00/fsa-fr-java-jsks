# OrderDesk — starter project (Lab 04)

A small, runnable slice of OrderDesk. It exists so you have real code to point an AI assistant
at: code you did not write, in a domain you do know.

**No dependencies to install.** Node 20 or later has a test runner built in.

```bash
node --version     # expect v20 or later
npm test           # or just: node --test
```

You should see every test pass before you start the lab. If it does not pass, fix that first —
step 7 asks you to write a check, and you cannot tell a new failure from an old one otherwise.

## Layout

```
src/cancellation.js   whether an order may be cancelled, and why not
src/returns.js        opening and approving returns — the file steps 6 to 10 change
src/orders.js         a few sample orders to work against
test/                 the tests, run by `node --test`
```

## What you are looking at

The rules this implements, from the OrderDesk domain:

- An order can ship in several shipments.
- The cancellation window closes when the **first** shipment dispatches. After that the
  customer returns rather than cancels.
- A refund must be approved by a refunds clerk, who must give a reason.

> The code does not implement all of that correctly. Finding out where it falls short — by
> reading it, not by asking — is part of the lab. Nothing here is sensitive, so it is safe to
> paste into the assistant; your own client work later is not.
