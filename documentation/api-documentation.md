# API Documentation

All `/api/*` routes except `/api/auth/login` require `Authorization: Bearer <JWT>`. Successful creates return 201; invalid input returns 400, invalid credentials 401, forbidden role 403, and duplicate key 409.

| Endpoint | Methods | Access | Purpose |
|---|---|---|---|
| `/auth/login` | POST | public | Email/password login |
| `/customers`, `/products`, `/categories` | GET, POST | read authenticated; mutations scoped | Search and manage master data |
| `/invoices` | GET, POST | staff/admin create | List and create totals-controlled invoices |
| `/payments` | GET, POST | staff/admin process | List or run mock gateway transaction |
| `/refunds` | POST | staff/admin | Refund valid successful payment |
| `/analytics/dashboard` | GET | staff/admin | Financial KPI cards |
| `/audit-logs` | GET | admin | Auditable security/financial events |

Invoice POST: `{customer_id,due_date,discount_amount,items:[{product_id,quantity,discount_amount}]}`. Payment POST: `{invoice_id,amount,payment_method}`. Refund POST: `{payment_id,amount,reason}`.
