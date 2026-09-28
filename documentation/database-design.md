# Database Design

The system is in 3NF: roles are separated from users; category values are referenced by products; an invoice has line items; payments and refunds are independent append-only financial events. Repeated calculated totals are controlled by `calculate_invoice_total`, not supplied by clients.

Key integrity mechanisms: FKs prevent orphan records, unique invoice/payment/refund references prevent duplicates, checks prevent negative values, and enums constrain lifecycle values. Deletion of invoice items cascades with the invoice while customers/products preserve history through soft deactivation or `SET NULL`.

`process_mock_payment` is an ACID unit: it validates the outstanding amount under lock, creates a processing payment, resolves the mock gateway, writes audit context, and commits only as a whole. A failed statement causes rollback. The status trigger updates the invoice only for successful states.

Triggers: timestamp touch triggers maintain `updated_at`; item mutation recalculates invoice totals; refund validation prevents failed-payment and over-refund cases; payment sync and audit preserve status and an immutable trail. Views provide read models for customer balances, payment history, revenue and outstanding invoices.
