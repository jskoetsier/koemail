# Changelog

All notable changes to KoeMail will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-09-23

### Added
- **Complete Email Server Infrastructure**
  - Docker-based architecture with docker-compose orchestration
  - PostgreSQL database with comprehensive schema for users, domains, aliases, and settings
  - Postfix SMTP server with virtual domain support and PostgreSQL backend
  - Dovecot IMAP/POP3 server with SQL authentication
  - Rspamd spam filtering with Redis backend for performance
  - ClamAV antivirus integration for malware protection
  - RainLoop modern webmail client for end-user email access

- **Management API & Backend**
  - Node.js REST API with Express.js framework
  - JWT-based authentication and authorization system
  - User management endpoints (create, read, update, delete)
  - Domain and alias management endpoints
  - Basic quota tracking and management endpoints
  - System health monitoring endpoint
  - React admin interface foundation (basic components - full functionality in development)

- **Security Features**
  - SSL/TLS support with automatic self-signed certificate generation
  - Password hashing with bcrypt (12 rounds)
  - Rate limiting on API endpoints
  - CORS configuration for secure cross-origin requests
  - Helmet.js security headers
  - Input validation with Joi schema validation

- **Database Schema**
  - Users table with quota management and admin roles
  - Domains table for virtual domain support
  - Aliases table for email forwarding
  - Spam quarantine system
  - Admin audit logging
  - System settings storage
  - API tokens for external access
  - Mail statistics tracking

- **Docker Services**
  - Custom PostgreSQL container with domain processing
  - Postfix container with environment-based configuration
  - Dovecot container with SQL authentication setup
  - Rspamd container with Redis integration
  - ClamAV container for virus scanning
  - RainLoop webmail container with Apache
  - Node.js API container with health checks
  - React admin UI container with Nginx

- **Deployment & Setup**
  - Automated setup script (`scripts/setup.sh`)
  - Environment configuration with `.env` file
  - Docker volume management for persistent data
  - Network isolation with custom Docker network
  - Automated password generation for security
  - Database initialization with default data

- **Documentation**
  - Comprehensive README with architecture overview
  - Installation and setup instructions
  - Project structure documentation
  - Default credentials and access information
  - Environment configuration guide

### Technical Details
- **Languages**: JavaScript (Node.js), React, SQL, Bash
- **Databases**: PostgreSQL 15, Redis 7
- **Email Services**: Postfix 3.x, Dovecot 2.x
- **Security**: Rspamd, ClamAV
- **Frontend**: React 18, Tailwind CSS
- **Backend**: Express.js, JWT, bcrypt
- **Deployment**: Docker, docker-compose
- **Development**: Modern ES6+, async/await patterns

### Configuration
- Support for custom domains (defaulting to koetsier.it)
- Configurable PostgreSQL credentials
- JWT secret configuration
- SSL certificate paths
- SMTP/IMAP/POP3 port configurations
- Spam filtering thresholds
- Storage quotas and limits

### Default Setup
- Domain: koetsier.it (configurable)
- Admin user: postmaster@koetsier.it
- Default password: postmaster123 (should be changed)
- Admin interface: http://localhost:3000
- Webmail: http://localhost:8080
- API: http://localhost:8000

### Security Considerations
- Default passwords should be changed immediately
- SSL certificates should be replaced with proper certificates for production
- Firewall rules should be configured appropriately
- Regular security updates recommended
- Backup strategies should be implemented

### Known Limitations
- Single-server deployment only
- Basic spam filtering (advanced rules planned for future versions)
- Limited webmail features compared to enterprise solutions
- No built-in backup/restore functionality
- Self-signed certificates for development only

### Performance
- Optimized for small to medium deployments (up to 1000 users)
- PostgreSQL with connection pooling
- Redis caching for improved performance
- Efficient Docker container resource usage
- Suitable for single-server deployments

---

## [Unreleased]

### Planned for Next Release (1.1.0)
- Complete React admin interface implementation
- Real-time dashboard statistics
- Enhanced user quota management
- Email queue monitoring
- Spam quarantine management interface
- API documentation with Swagger/OpenAPI
- Two-factor authentication for admin panel
- Improved error handling and logging

---

*This changelog will be updated with each release to track all changes, improvements, and bug fixes.*