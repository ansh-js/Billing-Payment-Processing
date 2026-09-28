BEGIN;

-- Temporary staging tables
CREATE TEMP TABLE stg_customers (
    customer_code text,
    full_name text,
    email text,
    phone text,
    city text,
    state text
);

CREATE TEMP TABLE stg_products (
    sku text,
    name text,
    category text,
    unit_price numeric,
    tax_rate numeric,
    stock_quantity integer
);

CREATE TEMP TABLE stg_invoices (
    invoice_number text,
    customer_code text,
    invoice_date date,
    due_date date,
    status text,
    discount_amount numeric
);

CREATE TEMP TABLE stg_invoice_items (
    invoice_number text,
    sku text,
    quantity integer,
    discount_amount numeric
);

CREATE TEMP TABLE stg_payments (
    transaction_reference text,
    invoice_number text,
    payment_method text,
    amount numeric,
    payment_date timestamptz,
    status text
);

CREATE TEMP TABLE stg_refunds (
    refund_reference text,
    transaction_reference text,
    amount numeric,
    reason text,
    status text,
    refund_date timestamptz
);

-- Load CSV files
\copy stg_customers FROM 'dataset/customers.csv' CSV HEADER
\copy stg_products FROM 'dataset/products.csv' CSV HEADER
\copy stg_invoices FROM 'dataset/invoices.csv' CSV HEADER
\copy stg_invoice_items FROM 'dataset/invoice_items.csv' CSV HEADER
\copy stg_payments FROM 'dataset/payments.csv' CSV HEADER
\copy stg_refunds FROM 'dataset/refunds.csv' CSV HEADER

-- Customers
INSERT INTO customers
(customer_code, full_name, email, phone, city, state)
SELECT
customer_code, full_name, email, phone, city, state
FROM stg_customers
ON CONFLICT (customer_code) DO NOTHING;

-- Products
INSERT INTO products
(sku, name, category, unit_price, tax_rate, stock_quantity)
SELECT
sku, name, category, unit_price, tax_rate, stock_quantity
FROM stg_products
ON CONFLICT (sku) DO NOTHING;

-- Invoices
INSERT INTO invoices
(invoice_number, customer_id, invoice_date, due_date, status, discount_amount)
SELECT
s.invoice_number,
c.customer_id,
s.invoice_date,
s.due_date,
s.status::invoice_status,
s.discount_amount
FROM stg_invoices s
JOIN customers c
ON c.customer_code = s.customer_code
ON CONFLICT (invoice_number) DO NOTHING;

-- Invoice items
INSERT INTO invoice_items
(invoice_id, product_id, quantity, discount_amount)
SELECT
i.invoice_id,
p.product_id,
s.quantity,
s.discount_amount
FROM stg_invoice_items s
JOIN invoices i
ON i.invoice_number = s.invoice_number
JOIN products p
ON p.sku = s.sku;

-- Payments
INSERT INTO payments
(transaction_reference, invoice_id, payment_method, amount, payment_date, status)
SELECT
s.transaction_reference,
i.invoice_id,
s.payment_method,
s.amount,
s.payment_date,
s.status::payment_status
FROM stg_payments s
JOIN invoices i
ON i.invoice_number = s.invoice_number
ON CONFLICT (transaction_reference) DO NOTHING;

-- Refunds
INSERT INTO refunds
(refund_reference, payment_id, amount, reason, status, refund_date)
SELECT
s.refund_reference,
p.payment_id,
s.amount,
s.reason,
s.status::refund_status,
s.refund_date
FROM stg_refunds s
JOIN payments p
ON p.transaction_reference = s.transaction_reference
ON CONFLICT (refund_reference) DO NOTHING;

COMMIT;
