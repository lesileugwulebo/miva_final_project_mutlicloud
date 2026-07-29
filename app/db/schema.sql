-- PostgreSQL Database Schema for Multi-Cloud Simulated Workload

CREATE TABLE IF NOT EXISTS customer (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    kyc_status VARCHAR(20) DEFAULT 'PENDING' CHECK (kyc_status IN ('PENDING', 'VERIFIED', 'FAILED'))
);

CREATE TABLE IF NOT EXISTS account (
    account_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(customer_id) ON DELETE CASCADE,
    account_type VARCHAR(20) DEFAULT 'SAVINGS' CHECK (account_type IN ('SAVINGS', 'CURRENT', 'LOAN')),
    currency VARCHAR(3) DEFAULT 'NGN',
    balance DECIMAL(15, 2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'SUSPENDED', 'CLOSED'))
);

CREATE TABLE IF NOT EXISTS transaction (
    transaction_id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES account(account_id) ON DELETE CASCADE,
    amount DECIMAL(15, 2) NOT NULL,
    direction VARCHAR(10) CHECK (direction IN ('INFLOW', 'OUTFLOW')),
    channel VARCHAR(20) DEFAULT 'MOBILE' CHECK (channel IN ('MOBILE', 'WEB', 'ATM', 'USSD', 'POS')),
    originating_cloud VARCHAR(10) CHECK (originating_cloud IN ('AWS', 'AZURE')),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit_log (
    log_id SERIAL PRIMARY KEY,
    transaction_id INTEGER REFERENCES transaction(transaction_id) ON DELETE SET NULL,
    event_type VARCHAR(50) NOT NULL,
    source_tier VARCHAR(20) DEFAULT 'APPLICATION' CHECK (source_tier IN ('WEB', 'APPLICATION', 'DATABASE')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_customer_email ON customer(email);
CREATE INDEX IF NOT EXISTS idx_account_customer ON account(customer_id);
CREATE INDEX IF NOT EXISTS idx_transaction_account ON transaction(account_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_transaction ON audit_log(transaction_id);

-- Insert Seed Data
INSERT INTO customer (full_name, email, phone, kyc_status) VALUES
('Lesile Ngozi', 'lesile.ngozi@miva.edu.ng', '+2348012345678', 'VERIFIED'),
('Theresa Ojewumi', 'theresa.ojewumi@miva.edu.ng', '+2348098765432', 'VERIFIED'),
('John Doe', 'john.doe@enterprise.com', '+2348123456789', 'PENDING')
ON CONFLICT (email) DO NOTHING;

INSERT INTO account (customer_id, account_type, currency, balance, status) VALUES
(1, 'CURRENT', 'NGN', 5000000.00, 'ACTIVE'),
(1, 'SAVINGS', 'NGN', 12500000.00, 'ACTIVE'),
(2, 'CURRENT', 'NGN', 750000.00, 'ACTIVE')
ON CONFLICT DO NOTHING;

INSERT INTO transaction (account_id, amount, direction, channel, originating_cloud) VALUES
(1, 150000.00, 'OUTFLOW', 'MOBILE', 'AWS'),
(2, 500000.00, 'INFLOW', 'WEB', 'AZURE')
ON CONFLICT DO NOTHING;

INSERT INTO audit_log (transaction_id, event_type, source_tier) VALUES
(1, 'FUNDS_TRANSFER_INITIATED', 'APPLICATION'),
(2, 'DIRECT_DEPOSIT_COMPLETED', 'APPLICATION')
ON CONFLICT DO NOTHING;
