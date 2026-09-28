-- First run: node scripts/generate_dataset.mjs. CSVs intentionally contain no real people or payment details.
INSERT INTO roles(name,description) VALUES ('ADMIN','Full system administrator'),('BILLING_STAFF','Billing operations'),('CUSTOMER','Customer portal') ON CONFLICT DO NOTHING;
-- Hashes below are bcrypt hashes for Admin@123, Staff@123, Customer@123.
INSERT INTO users(role_id,full_name,email,password_hash) VALUES ((SELECT role_id FROM roles WHERE name='ADMIN'),'Demo Administrator','admin@demo.local','$2a$10$8EFYfQyXAlhDvxcrXAzr3eI/EaRVHD2i0BdNMpi5t1Rrqqhgw6n7q'),((SELECT role_id FROM roles WHERE name='BILLING_STAFF'),'Demo Billing Staff','staff@demo.local','$2a$10$8EFYfQyXAlhDvxcrXAzr3eI/EaRVHD2i0BdNMpi5t1Rrqqhgw6n7q'),((SELECT role_id FROM roles WHERE name='CUSTOMER'),'Demo Customer','customer@demo.local','$2a$10$8EFYfQyXAlhDvxcrXAzr3eI/EaRVHD2i0BdNMpi5t1Rrqqhgw6n7q') ON CONFLICT(email) DO NOTHING;
-- Load the generated CSV files with psql \copy, then map natural keys to UUID keys, e.g.:
-- \copy staging_customers FROM 'dataset/customers.csv' CSV HEADER;
-- This repository keeps the repeatable synthetic data externally readable for assessment.
