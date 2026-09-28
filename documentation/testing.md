# Testing

| Test | Expected outcome |
|---|---|
| Customer insert / duplicate email | Created / unique violation (409) |
| Invoice with items | Trigger computes subtotal, tax and total |
| Empty invoice | Validation rollback |
| Successful mock payment | Payment, audit and invoice status committed atomically |
| Failed mock payment | Invoice remains unpaid |
| Partial payment | Invoice becomes `PARTIALLY_PAID` |
| Overpayment | Procedure raises exception and rolls back |
| Refund > payment / failed payment | Refund trigger rejects |
| Duplicate transaction reference | Unique constraint rejects |
| Customer calls audit endpoint | 403 |
| Missing/invalid JWT | 401 |

Run integration tests against a disposable database; execute `database/sample_queries.sql` after seeding to validate analytics and explain plans.
