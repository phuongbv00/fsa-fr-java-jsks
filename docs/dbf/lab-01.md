# Lab 01 — Model the OrderDesk returns domain

**Duration:** 90 min

## Objectives

By the end of this lab you will be able to:

- Extract entities, attributes and relationships from a written domain description.
- Assign and justify cardinality at both ends of every relationship.
- Choose a primary key per entity and defend it against the alternatives.
- Identify a functional dependency that violates 3NF and correct it.

## Before you start

- You have read [Relational Modelling & Normalization](relational-modelling.md).
- You can render Mermaid — the VS Code Markdown preview, or <https://mermaid.live>.
- You have a Git repository for this module with a `docs/` folder.

## The brief

The OrderDesk stakeholder has sent one page of notes about **stock and suppliers**. This is a
part of the domain the study guide has not modelled for you.

> Products come from suppliers. A supplier has a name, a contact email and a country. Most
> products come from one supplier, but a few can be bought from two or three, at different
> prices and with different lead times in days.
>
> We hold stock in more than one warehouse. For each product in each warehouse we need to know
> how many units are on hand. A product can be stocked nowhere at all.
>
> When stock runs low someone raises a purchase order to a supplier. A purchase order lists
> products and quantities, has a raised date, an expected date, and a state that is one of
> draft, sent, part-received or closed. It is raised by a member of staff.
>
> Deliveries arrive against a purchase order. One purchase order can be delivered in several
> deliveries, and a delivery can be short — we record how many of each product actually came.

## Steps

1. **List the nouns.** Go through the brief and write every noun into a table with one of three
   labels: `entity`, `attribute of <entity>`, or `not data`. Do this before drawing anything.
   Expect to argue with yourself about at least two of them.

2. **Write the cardinality sentences.** For every pair of entities that are related, write both
   directions in full, as in the note:

   ```text
   For one SUPPLIER, how many PRODUCT? ......
   For one PRODUCT, how many SUPPLIER? ......
   ```

   Keep this list; step 6 asks you to justify against it.

3. **Resolve the many-to-many relationships.** For each one, name the junction entity for what
   it *is*, and give it the attributes the brief implies. The supplier/product relationship has
   two attributes hiding in the brief — find them.

4. **Draw the ERD** as Mermaid in `docs/erd.md`, with primary and foreign keys marked:

   ```mermaid
   erDiagram
       SUPPLIER {
           bigint supplier_id PK
           text   contact_email "UNIQUE"
       }
       SUPPLIER ||--o{ SUPPLIER_PRODUCT : offers
   ```

5. **Choose the keys.** For each entity, write one line naming the primary key and one line
   saying what you rejected and why. At least one entity has a plausible natural key; say
   explicitly why you did or did not use it.

6. **Justify every relationship.** Under the diagram, one line per relationship, in this form:

   ```text
   PURCHASE_ORDER ||--|{ PURCHASE_ORDER_LINE
     A purchase order with no lines is not a purchase order, so the child end is one-or-more.
     Enforced by: application, at creation — a foreign key cannot require a child to exist.
   ```

7. **Normalize the supplied table.** This denormalized table is in `docs/anomalies.md`:

   ```text
   po_line_id | po_id | supplier_name | supplier_email    | sku   | product_name | qty | lead_days
   -----------+-------+---------------+-------------------+-------+--------------+-----+----------
   1          | 900   | Kaito Parts   | sales@kaito.example| KB-01 | Keyboard     | 50  | 7
   2          | 900   | Kaito Parts   | sales@kaito.example| MS-04 | Mouse        | 20  | 7
   3          | 901   | Kaito Parts   | sales@kaito.example| KB-01 | Keyboard     | 30  | 7
   ```

   Write out the functional dependencies, name the highest normal form it satisfies, and give
   the decomposition that reaches 3NF.

8. **Name one anomaly, with rows.** In `docs/anomalies.md`, describe one update, one insertion
   and one deletion anomaly the table above permits. Each must name specific rows and say what
   goes wrong — not "data could become inconsistent".

## Acceptance

- [ ] `docs/erd.md` renders, and shows every entity from the brief with its keys marked.
- [ ] Every relationship has cardinality at both ends, and no relationship is many-to-many.
- [ ] The supplier/product junction carries both price and lead time.
- [ ] Every entity has one line naming its primary key and one line naming a rejected alternative.
- [ ] Every relationship has a justification sentence in domain terms.
- [ ] `docs/anomalies.md` lists the functional dependencies of the supplied table.
- [ ] The 3NF decomposition removes every dependency whose determinant is not a key.
- [ ] Three anomalies are described, each naming specific rows.

> **Tip.** If a relationship's justification reads "because that makes sense", you have not
> found the domain rule yet. Go back to the sentence in the brief that forced it.

---

Next: [DDL, Constraints & Data Integrity](ddl-and-constraints.md).
