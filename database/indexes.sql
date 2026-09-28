-- Targeted indexes for primary access paths; each increases write/storage cost.
CREATE INDEX idx_customers_search ON customers USING gin (to_tsvector('simple',full_name||' '||email||' '||COALESCE(phone,'')));
CREATE INDEX idx_products_category_active ON products(category_id) WHERE is_active;
CREATE INDEX idx_invoices_customer_date ON invoices(customer_id,invoice_date DESC);
CREATE INDEX idx_invoices_open_due ON invoices(due_date) WHERE status IN ('PENDING','PARTIALLY_PAID','OVERDUE');
CREATE INDEX idx_payments_invoice_success ON payments(invoice_id,payment_date DESC) WHERE status IN ('SUCCESSFUL','PARTIALLY_REFUNDED');
CREATE INDEX idx_payments_status_date ON payments(status,payment_date DESC);
CREATE INDEX idx_refunds_payment ON refunds(payment_id,status);
CREATE INDEX idx_audit_entity_time ON audit_logs(entity_type,entity_id,created_at DESC);
