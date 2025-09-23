-- Default data for KoeMail
-- This file inserts initial data and configuration

-- Insert default domain (will be replaced by entrypoint script)
INSERT INTO domains (domain, description, active) VALUES 
('__DOMAIN__', 'Default domain for KoeMail server', TRUE);

-- Insert default system settings
INSERT INTO system_settings (key, value, type, description) VALUES
('smtp_hostname', 'mail.__DOMAIN__', 'string', 'SMTP server hostname'),
('max_message_size', '25600000', 'integer', 'Maximum message size in bytes (25MB)'),
('default_quota', '1073741824', 'integer', 'Default user quota in bytes (1GB)'),
('spam_threshold', '5.0', 'string', 'Spam score threshold for rejection'),
('virus_scanning_enabled', 'true', 'boolean', 'Enable virus scanning'),
('spam_quarantine_days', '30', 'integer', 'Days to keep spam in quarantine'),
('backup_retention_days', '90', 'integer', 'Days to keep backups'),
('enable_user_spam_controls', 'true', 'boolean', 'Allow users to manage spam settings'),
('smtp_auth_required', 'true', 'boolean', 'Require SMTP authentication'),
('max_recipients_per_message', '50', 'integer', 'Maximum recipients per message'),
('rate_limit_per_hour', '100', 'integer', 'Maximum messages per user per hour'),
('enable_dkim', 'true', 'boolean', 'Enable DKIM signing'),
('enable_spf', 'true', 'boolean', 'Enable SPF checking'),
('enable_dmarc', 'true', 'boolean', 'Enable DMARC policy');

-- Create postmaster@__DOMAIN__ (required by RFC)
-- Password: 'postmaster123' (hashed with bcrypt)
INSERT INTO users (email, password, name, domain_id, admin, active) 
SELECT 
    'postmaster@__DOMAIN__',
    '$2b$10$rOkjKLWUeMPPrqnZgLI8..NZW8QjBBLvVyPgFvPPwmFh7PrFxJ32u',
    'Postmaster',
    d.id,
    TRUE,
    TRUE
FROM domains d WHERE d.domain = '__DOMAIN__';

-- Create initial quota usage record for postmaster
INSERT INTO quota_usage (user_id, bytes_used, message_count)
SELECT u.id, 0, 0
FROM users u WHERE u.email = 'postmaster@__DOMAIN__';

-- Create some common aliases
INSERT INTO aliases (source, destination, domain_id, active)
SELECT 
    alias_source,
    'postmaster@__DOMAIN__',
    d.id,
    TRUE
FROM domains d, (VALUES 
    ('abuse@__DOMAIN__'),
    ('admin@__DOMAIN__'),
    ('hostmaster@__DOMAIN__'),
    ('mailer-daemon@__DOMAIN__'),
    ('noreply@__DOMAIN__'),
    ('no-reply@__DOMAIN__'),
    ('webmaster@__DOMAIN__')
) AS aliases(alias_source)
WHERE d.domain = '__DOMAIN__';
