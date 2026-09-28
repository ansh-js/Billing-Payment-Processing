# Scalable Database-Driven Billing and Payment Processing System

A II B.Tech Database Engineering project demonstrating transaction-safe invoicing, mock payments, refunds, auditing, role-based access, reporting, PostgreSQL views, functions, procedures, triggers, and targeted indexing. It never processes real financial data.

## Stack and architecture

React + Vite + Bootstrap → Express REST API → PostgreSQL 15+. The API uses parameterized `pg` queries, bcrypt password hashes, JWT sessions, and a PostgreSQL procedure for mock payment processing.

## Quick start

1. Create PostgreSQL database: `createdb billing_db`.
2. In project root, run SQL in this order: `schema.sql`, `functions.sql`, `triggers.sql`, `indexes.sql`, `views.sql`, `procedures.sql`, `seed.sql`.
3. Copy `.env.example` to `source-code/backend/.env` and supply a strong JWT secret.
4. `cd source-code/backend && npm install && npm run dev`
5. `cd source-code/frontend && npm install && npm run dev`
6. Optionally create the requested synthetic CSV records: `node scripts/generate_dataset.mjs`.

## Demo credentials

| Role | Email | Password |
|---|---|---|
| Admin | admin@demo.local | Admin@123 |
| Billing staff | staff@demo.local | Staff@123 |
| Customer | customer@demo.local | Customer@123 |

## Main REST paths

`/api/auth/login`, `/api/customers`, `/api/products`, `/api/categories`, `/api/invoices`, `/api/payments`, `/api/refunds`, `/api/analytics/dashboard`, and `/api/audit-logs`. See `documentation/api-documentation.md`.

## Database engineering evidence

- 3NF operational tables with UUID primary keys, FKs, unique keys, enum/check constraints.
- Atomic payment procedure: payment initiation, simulated gateway result, invoice-status trigger and audit insertion execute in one transaction.
- Refund trigger locks the payment and rejects invalid state or cumulative over-refund.
- Views support dashboard/reports without exposing implementation queries.
- Partial/composite/GiST search indexes target real filters. `sample_queries.sql` includes joins, CTE, subquery, window function and `EXPLAIN ANALYZE`.

Read the documentation folder for testing, security, performance, literature review, gap analysis, and the report. Screenshots can be captured after launching the local UI.
