# OrderDesk — returns and refunds

Raw notes from a meeting with Linh (Operations Lead) and Tuan (Customer Service), taken by a
business analyst who was writing fast. Not edited, not tidied up.

> These notes are the input for Lab 01. They are deliberately incomplete and contradict
> themselves in places. That is normal, and finding the gaps is the exercise — do not assume
> anything here is authoritative just because it is written down.

---

Linh: the big problem is refunds take too long. Customers ring up twice before they see the
money. Sometimes three times.

Tuan: it's not the refund, it's that nobody knows where the return is. We can't see whether
the parcel arrived back.

Linh: right. So we want a screen. Staff open the order, click Return, and it's done.

Tuan: it's never one click though. Sometimes only part of the order comes back. Someone orders
three keyboards, sends one back.

Linh: fine, per item then.

---

**Rules (Linh)**

- Customer has 30 days to return. From when they got it.
- Actually Tuan says 30 days from the order date. Need to check which. Marketing put "one
  month" on the website.
- Faulty goods are different, that's 6 months, but that's a legal thing, don't build it now.
- Refund needs approval. Only the refunds clerks can approve.
- The clerk has to say why. We had an audit issue last year.

**Tuan disagrees on approval**

Tuan: for small amounts we shouldn't need approval, it's just slow. Under 200,000 maybe?

Linh: no. Everything gets approved. ... though actually for under 100,000 I could live with
automatic. Let's say we discuss it.

---

Refund goes back to the original payment method. Unless they paid cash on delivery, then it's
a bank transfer and someone has to key in the account number.

Tuan: can we not store the bank details? Last time we had a spreadsheet.

Nobody answered this.

---

**Things people said they wanted, in no particular order**

- See all open returns in one list, oldest first
- Know which returns are waiting on the customer vs waiting on us
- Print a returns label. Tuan says the courier gives us these, Linh thinks we generate them.
- Email the customer when the refund goes through
- Stop customers returning things that were on final clearance
- A report at the end of the month. Linh wasn't sure what would be on it.
- "It should be like the Shopee flow" — nobody wrote down what that means

---

**The awkward bit**

An order can go out in several parcels. If the first parcel has already been dispatched, the
customer cannot cancel the order any more — they have to return it instead. Linh was firm on
this.

But Tuan then said sometimes he cancels the second parcel if it hasn't left the warehouse, and
nobody had a problem with that. These two statements are not compatible and we did not resolve
it in the meeting.

---

Linh: also while we're in there, can we fix the search? It's terrible.

Meeting ended, ran out of time.
