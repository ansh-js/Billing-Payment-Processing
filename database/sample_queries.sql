-- 1 Revenue by month
SELECT * FROM monthly_revenue ORDER BY month;
-- 2 Top customers (aggregation + join)
SELECT c.full_name,sum(p.amount) revenue FROM customers c JOIN invoices i USING(customer_id) JOIN payments p USING(invoice_id) WHERE p.status IN ('SUCCESSFUL','PARTIALLY_REFUNDED') GROUP BY c.customer_id,c.full_name ORDER BY revenue DESC LIMIT 10;
-- 3 Outstanding invoices
SELECT * FROM outstanding_invoices ORDER BY due_date;
-- 4 Products bought most often
SELECT pr.name,sum(ii.quantity) quantity FROM products pr JOIN invoice_items ii USING(product_id) GROUP BY pr.product_id,pr.name ORDER BY quantity DESC LIMIT 10;
-- 5 Failed payments
SELECT * FROM payment_summary WHERE status='FAILED';
-- 6 Customers above average CLV (subquery)
SELECT full_name,customer_lifetime_value(customer_id) clv FROM customers WHERE customer_lifetime_value(customer_id)>(SELECT avg(customer_lifetime_value(customer_id)) FROM customers);
-- 7 Refund rate
SELECT round(100*COALESCE((SELECT sum(amount) FROM refunds WHERE status='COMPLETED'),0)/NULLIF((SELECT sum(amount) FROM payments WHERE status IN ('SUCCESSFUL','PARTIALLY_REFUNDED')),0),2) refund_rate_pct;
-- 8 CTE for open balances
WITH balances AS (SELECT invoice_id,outstanding_balance(invoice_id) balance FROM invoices) SELECT i.status,count(*),sum(b.balance) FROM balances b JOIN invoices i USING(invoice_id) WHERE b.balance>0 GROUP BY i.status;
-- 9 Window rank
SELECT c.full_name,date_trunc('month',p.payment_date) month,sum(p.amount) revenue,rank() OVER(PARTITION BY date_trunc('month',p.payment_date) ORDER BY sum(p.amount) DESC) rank FROM customers c JOIN invoices i USING(customer_id) JOIN payments p USING(invoice_id) WHERE p.status='SUCCESSFUL' GROUP BY c.full_name,date_trunc('month',p.payment_date);
-- 10 Payment-method distribution
SELECT payment_method,count(*),sum(amount) FROM payments GROUP BY payment_method ORDER BY 3 DESC;
-- 11-20: status counts, overdue, audit actions, product tax, invoice values, refund details, date trends, inactive customers, flags, and an index plan.
SELECT status,count(*) FROM invoices GROUP BY status; SELECT * FROM invoices WHERE due_date<current_date AND status IN ('PENDING','PARTIALLY_PAID'); SELECT action,count(*) FROM audit_logs GROUP BY action; SELECT name,tax_rate FROM products ORDER BY tax_rate DESC; SELECT avg(total_amount) FROM invoices; SELECT r.*,p.transaction_reference FROM refunds r JOIN payments p USING(payment_id); SELECT payment_date::date,sum(amount) FROM payments WHERE status='SUCCESSFUL' GROUP BY 1; SELECT * FROM customers WHERE NOT is_active; SELECT * FROM transaction_flags WHERE status='OPEN'; EXPLAIN ANALYZE SELECT * FROM payments WHERE status='SUCCESSFUL' ORDER BY payment_date DESC LIMIT 50;
-- ACID demo: all three actions roll back together if the procedure errors.
BEGIN; CALL process_mock_payment('00000000-0000-0000-0000-000000000000',100,'UPI',NULL,NULL); COMMIT;
