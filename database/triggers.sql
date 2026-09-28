CREATE OR REPLACE FUNCTION touch_updated_at() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN NEW.updated_at=now(); RETURN NEW; END $$;
CREATE OR REPLACE FUNCTION item_recalculate() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN PERFORM calculate_invoice_total(COALESCE(NEW.invoice_id,OLD.invoice_id)); RETURN COALESCE(NEW,OLD); END $$;
CREATE OR REPLACE FUNCTION reject_invalid_refund() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE paid NUMERIC; refunded NUMERIC; payment_state payment_status; BEGIN
 SELECT amount,status INTO paid,payment_state FROM payments WHERE payment_id=NEW.payment_id FOR UPDATE;
 IF payment_state NOT IN ('SUCCESSFUL','PARTIALLY_REFUNDED') THEN RAISE EXCEPTION 'Only successful payments may be refunded'; END IF;
 SELECT COALESCE(sum(amount),0) INTO refunded FROM refunds WHERE payment_id=NEW.payment_id AND status IN ('PENDING','COMPLETED');
 IF refunded+NEW.amount > paid THEN RAISE EXCEPTION 'Refund exceeds refundable payment amount'; END IF; RETURN NEW; END $$;
CREATE OR REPLACE FUNCTION sync_invoice_after_payment() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE balance NUMERIC; BEGIN
 IF NEW.status IN ('SUCCESSFUL','PARTIALLY_REFUNDED') THEN balance:=outstanding_balance(NEW.invoice_id); UPDATE invoices SET status=CASE WHEN balance=0 THEN 'PAID' WHEN balance<total_amount THEN 'PARTIALLY_PAID' ELSE 'PENDING' END WHERE invoice_id=NEW.invoice_id; END IF; RETURN NEW; END $$;
CREATE OR REPLACE FUNCTION audit_payment() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN INSERT INTO audit_logs(user_id,action,entity_type,entity_id,metadata) VALUES(NEW.initiated_by,'PAYMENT_'||NEW.status,'payment',NEW.payment_id,jsonb_build_object('amount',NEW.amount,'reference',NEW.transaction_reference)); RETURN NEW; END $$;
CREATE TRIGGER users_touch BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER customers_touch BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER products_touch BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER invoices_touch BEFORE UPDATE ON invoices FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER payments_touch BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER invoice_item_totals AFTER INSERT OR UPDATE OR DELETE ON invoice_items FOR EACH ROW EXECUTE FUNCTION item_recalculate();
CREATE TRIGGER validate_refund BEFORE INSERT ON refunds FOR EACH ROW EXECUTE FUNCTION reject_invalid_refund();
CREATE TRIGGER payment_invoice_sync AFTER INSERT OR UPDATE OF status ON payments FOR EACH ROW EXECUTE FUNCTION sync_invoice_after_payment();
CREATE TRIGGER payment_audit AFTER INSERT OR UPDATE OF status ON payments FOR EACH ROW EXECUTE FUNCTION audit_payment();
