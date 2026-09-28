-- PostgreSQL 15+. Run files in README order.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE user_role AS ENUM ('ADMIN','BILLING_STAFF','CUSTOMER');
CREATE TYPE invoice_status AS ENUM ('DRAFT','PENDING','PARTIALLY_PAID','PAID','OVERDUE','CANCELLED');
CREATE TYPE payment_status AS ENUM ('PENDING','PROCESSING','SUCCESSFUL','FAILED','REFUNDED','PARTIALLY_REFUNDED');
CREATE TYPE payment_method AS ENUM ('CASH','CARD','UPI','BANK_TRANSFER','WALLET');
CREATE TYPE refund_status AS ENUM ('PENDING','COMPLETED','FAILED','CANCELLED');

CREATE TABLE roles (role_id SMALLSERIAL PRIMARY KEY, name user_role UNIQUE NOT NULL, description TEXT NOT NULL);
CREATE TABLE users (
 user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), role_id SMALLINT NOT NULL REFERENCES roles(role_id),
 full_name VARCHAR(120) NOT NULL, email VARCHAR(254) UNIQUE NOT NULL, password_hash TEXT NOT NULL,
 is_active BOOLEAN NOT NULL DEFAULT TRUE, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE customers (
 customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID UNIQUE REFERENCES users(user_id) ON DELETE SET NULL,
 customer_code VARCHAR(20) UNIQUE NOT NULL, full_name VARCHAR(120) NOT NULL, email VARCHAR(254) UNIQUE NOT NULL,
 phone VARCHAR(25), billing_address TEXT, city VARCHAR(80), state VARCHAR(80), is_active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE categories (category_id SERIAL PRIMARY KEY, name VARCHAR(80) UNIQUE NOT NULL, description TEXT, is_active BOOLEAN NOT NULL DEFAULT TRUE);
CREATE TABLE products (
 product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), category_id INT NOT NULL REFERENCES categories(category_id), sku VARCHAR(40) UNIQUE NOT NULL,
 name VARCHAR(140) NOT NULL, description TEXT, unit_price NUMERIC(12,2) NOT NULL CHECK(unit_price >= 0), tax_rate NUMERIC(5,2) NOT NULL DEFAULT 18 CHECK(tax_rate BETWEEN 0 AND 100),
 stock_quantity INT NOT NULL DEFAULT 0 CHECK(stock_quantity >= 0), is_active BOOLEAN NOT NULL DEFAULT TRUE, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE invoices (
 invoice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), invoice_number VARCHAR(30) UNIQUE NOT NULL, customer_id UUID NOT NULL REFERENCES customers(customer_id),
 invoice_date DATE NOT NULL DEFAULT current_date, due_date DATE NOT NULL, status invoice_status NOT NULL DEFAULT 'DRAFT',
 subtotal NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK(subtotal >= 0), tax_amount NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK(tax_amount >= 0), discount_amount NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK(discount_amount >= 0),
 total_amount NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK(total_amount >= 0), notes TEXT, created_by UUID REFERENCES users(user_id), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), CHECK(due_date >= invoice_date)
);
CREATE TABLE invoice_items (
 invoice_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), invoice_id UUID NOT NULL REFERENCES invoices(invoice_id) ON DELETE CASCADE, product_id UUID REFERENCES products(product_id) ON DELETE SET NULL,
 item_description VARCHAR(250) NOT NULL, quantity NUMERIC(12,2) NOT NULL CHECK(quantity > 0), unit_price NUMERIC(12,2) NOT NULL CHECK(unit_price >= 0), tax_rate NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK(tax_rate BETWEEN 0 AND 100), discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK(discount_amount >= 0)
);
CREATE TABLE payments (
 payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), invoice_id UUID NOT NULL REFERENCES invoices(invoice_id), transaction_reference VARCHAR(48) UNIQUE NOT NULL,
 payment_method payment_method NOT NULL, amount NUMERIC(14,2) NOT NULL CHECK(amount > 0), payment_date TIMESTAMPTZ NOT NULL DEFAULT now(), status payment_status NOT NULL DEFAULT 'PENDING', gateway_response JSONB NOT NULL DEFAULT '{}'::jsonb, initiated_by UUID REFERENCES users(user_id), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE refunds (
 refund_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), payment_id UUID NOT NULL REFERENCES payments(payment_id), refund_reference VARCHAR(48) UNIQUE NOT NULL,
 amount NUMERIC(14,2) NOT NULL CHECK(amount > 0), reason TEXT NOT NULL, status refund_status NOT NULL DEFAULT 'PENDING', refund_date TIMESTAMPTZ NOT NULL DEFAULT now(), processed_by UUID REFERENCES users(user_id), created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE audit_logs (audit_id BIGSERIAL PRIMARY KEY, user_id UUID REFERENCES users(user_id) ON DELETE SET NULL, action VARCHAR(80) NOT NULL, entity_type VARCHAR(60) NOT NULL, entity_id UUID, ip_address INET, metadata JSONB NOT NULL DEFAULT '{}'::jsonb, created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE transaction_flags (flag_id BIGSERIAL PRIMARY KEY, payment_id UUID NOT NULL REFERENCES payments(payment_id) ON DELETE CASCADE, risk_type VARCHAR(60) NOT NULL, risk_score SMALLINT NOT NULL CHECK(risk_score BETWEEN 1 AND 100), description TEXT NOT NULL, status VARCHAR(20) NOT NULL DEFAULT 'OPEN' CHECK(status IN ('OPEN','REVIEWED','DISMISSED')), created_at TIMESTAMPTZ NOT NULL DEFAULT now());
GRANT USAGE ON SCHEMA public TO PUBLIC;
