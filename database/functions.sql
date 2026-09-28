CREATE OR REPLACE FUNCTION calculate_invoice_total(p_invoice UUID) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
 UPDATE invoices i SET subtotal=x.subtotal, tax_amount=x.tax, discount_amount=x.discount,
 total_amount=GREATEST(0,x.subtotal+x.tax-x.discount), updated_at=now()
 FROM (SELECT invoice_id, COALESCE(sum(quantity*unit_price),0) subtotal, COALESCE(sum((quantity*unit_price-discount_amount)*tax_rate/100),0) tax, COALESCE(sum(discount_amount),0) discount FROM invoice_items WHERE invoice_id=p_invoice GROUP BY invoice_id) x WHERE i.invoice_id=x.invoice_id;
END $$;
CREATE OR REPLACE FUNCTION outstanding_balance(p_invoice UUID) RETURNS NUMERIC LANGUAGE sql STABLE AS $$
 SELECT GREATEST(0,i.total_amount-COALESCE((SELECT sum(p.amount) FROM payments p WHERE p.invoice_id=i.invoice_id AND p.status IN ('SUCCESSFUL','PARTIALLY_REFUNDED')),0)) FROM invoices i WHERE i.invoice_id=p_invoice $$;
CREATE OR REPLACE FUNCTION customer_lifetime_value(p_customer UUID) RETURNS NUMERIC LANGUAGE sql STABLE AS $$
 SELECT COALESCE(sum(p.amount),0) FROM payments p JOIN invoices i ON i.invoice_id=p.invoice_id WHERE i.customer_id=p_customer AND p.status IN ('SUCCESSFUL','PARTIALLY_REFUNDED') $$;
