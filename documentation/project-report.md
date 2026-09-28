# Project Report: Scalable Database-Driven Billing and Payment Processing System

## 1. Introduction
Billing operations require correct balances, predictable status changes and traceable financial events. This project prevents common spreadsheet/manual workflow errors through a normalized relational system. Objectives are secure role access, backend-controlled invoice maths, simulated payment processing, safe refunds and useful reporting. The scope is academic mock processing, not real monetary transfer.

## 2. Literature and gap
The literature matrix and critical comparison are in `literature-review.md`; the evidence-based integration gap is documented in `gap-analysis.md`.

## 3. Analysis
Users manage customers/products, issue invoices, process mock payments/refunds, and view reports. Non-functional needs: integrity, confidentiality, responsiveness, maintainability and auditable events.

## 4. Design
React calls Express over REST; Express calls PostgreSQL. Core relationships are Customer 1:N Invoice, Invoice 1:N Item/Payment, Payment 1:N Refund, and Role 1:N User. The data flow validates API input, begins a DB transaction, applies state change/triggers, commits and returns sanitized JSON.

## 5–6. Implementation and database engineering
See the SQL folder for schema, indexes, views, functions, procedure, triggers and sample queries. PostgreSQL enforces normalized reference data, FKs, checks and unique transaction identifiers. Calculations run in SQL; the payment procedure demonstrates ACID commit/rollback.

## 7. Testing
The test matrix in `testing.md` covers normal, authorization and financial edge cases.

## 8. Performance
Partial/composite indexes are based on actual listing and work-queue predicates; exact plans should be captured locally using `EXPLAIN ANALYZE` after loading data.

## 9–10. Results and conclusion
The dashboard exposes customers, invoices, revenue, refunds, outstanding amount and success rate. The result is a working database-centric foundation; future work is listed in `future-enhancements.md`.
