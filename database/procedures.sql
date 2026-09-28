CREATE OR REPLACE PROCEDURE process_mock_payment(p_invoice UUID,p_amount NUMERIC,p_method payment_method,p_actor UUID,OUT p_reference TEXT) LANGUAGE plpgsql AS $$
DECLARE remaining NUMERIC; BEGIN
 IF p_amount<=0 THEN RAISE EXCEPTION 'Payment amount must be positive'; END IF;
 SELECT outstanding_balance(p_invoice) INTO remaining FOR UPDATE; IF remaining IS NULL THEN RAISE EXCEPTION 'Invoice not found'; END IF; IF p_amount>remaining THEN RAISE EXCEPTION 'Payment exceeds outstanding balance'; END IF;
 p_reference:='TXN-'||to_char(clock_timestamp(),'YYYYMMDDHH24MISSMS')||'-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,6));
 INSERT INTO payments(invoice_id,transaction_reference,payment_method,amount,status,gateway_response,initiated_by) VALUES(p_invoice,p_reference,p_method,p_amount,'PROCESSING',jsonb_build_object('provider','AcademicMock','stage','processing'),p_actor);
 UPDATE payments SET status=CASE WHEN random()<0.90 THEN 'SUCCESSFUL' ELSE 'FAILED' END,gateway_response=jsonb_build_object('provider','AcademicMock','message','simulated gateway result') WHERE transaction_reference=p_reference;
 INSERT INTO audit_logs(user_id,action,entity_type,entity_id,metadata) SELECT p_actor,'PAYMENT_INITIATED','invoice',p_invoice,jsonb_build_object('reference',p_reference);
END $$;
