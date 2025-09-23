-- KoeMail Database Schema
-- This file initializes the PostgreSQL database with all necessary tables

-- Domains table
CREATE TABLE domains (
    id SERIAL PRIMARY KEY,
    domain VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Users table (virtual users)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Encrypted password
    name VARCHAR(255),
    domain_id INTEGER REFERENCES domains(id) ON DELETE CASCADE,
    quota BIGINT DEFAULT 1073741824, -- Default 1GB in bytes
    active BOOLEAN DEFAULT TRUE,
    admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE
);

-- Aliases table
CREATE TABLE aliases (
    id SERIAL PRIMARY KEY,
    source VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    domain_id INTEGER REFERENCES domains(id) ON DELETE CASCADE,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Mail quota usage tracking
CREATE TABLE quota_usage (
    user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    bytes_used BIGINT DEFAULT 0,
    message_count INTEGER DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Spam quarantine
CREATE TABLE spam_quarantine (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    message_id VARCHAR(255) NOT NULL,
    sender VARCHAR(255),
    recipient VARCHAR(255),
    subject TEXT,
    spam_score DECIMAL(5,2),
    quarantine_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    released BOOLEAN DEFAULT FALSE,
    released_at TIMESTAMP WITH TIME ZONE,
    message_content TEXT -- Base64 encoded message content
);

-- Admin logs
CREATE TABLE admin_logs (
    id SERIAL PRIMARY KEY,
    admin_user_id INTEGER REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50), -- 'user', 'domain', 'alias', etc.
    target_id INTEGER,
    details JSONB,
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- System settings
CREATE TABLE system_settings (
    key VARCHAR(100) PRIMARY KEY,
    value TEXT,
    type VARCHAR(20) DEFAULT 'string', -- 'string', 'integer', 'boolean', 'json'
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- API tokens for external access
CREATE TABLE api_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    permissions JSONB DEFAULT '[]'::jsonb,
    expires_at TIMESTAMP WITH TIME ZONE,
    last_used TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Mail statistics
CREATE TABLE mail_stats (
    id SERIAL PRIMARY KEY,
    domain_id INTEGER REFERENCES domains(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    sent_count INTEGER DEFAULT 0,
    received_count INTEGER DEFAULT 0,
    spam_count INTEGER DEFAULT 0,
    virus_count INTEGER DEFAULT 0,
    bounced_count INTEGER DEFAULT 0,
    UNIQUE(domain_id, date)
);

-- Indexes for performance
CREATE INDEX idx_users_domain_id ON users(domain_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_active ON users(active);
CREATE INDEX idx_aliases_domain_id ON aliases(domain_id);
CREATE INDEX idx_aliases_source ON aliases(source);
CREATE INDEX idx_spam_quarantine_user_id ON spam_quarantine(user_id);
CREATE INDEX idx_spam_quarantine_date ON spam_quarantine(quarantine_date);
CREATE INDEX idx_admin_logs_admin_user_id ON admin_logs(admin_user_id);
CREATE INDEX idx_admin_logs_created_at ON admin_logs(created_at);
CREATE INDEX idx_mail_stats_domain_date ON mail_stats(domain_id, date);

-- Triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_domains_updated_at BEFORE UPDATE ON domains
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_system_settings_updated_at BEFORE UPDATE ON system_settings
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
