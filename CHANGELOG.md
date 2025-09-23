# Changelog

All notable changes to KoeMail will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-09-23

### Added
- **Full SASL Authentication System**
  - TCP-based SASL authentication between Postfix and Dovecot
  - Secure inter-container communication via dedicated network ports
  - Support for PLAIN and LOGIN authentication mechanisms
  - Proper authentication service configuration for mail client access

- **Advanced Spam Filtering Integration**
  - Complete rspamd milter protocol integration with Postfix
  - Redis-backed rspamd configuration for high performance
  - Proper milter worker configuration for real-time scanning
  - Spam filtering for both incoming and outgoing messages

- **Production-Ready Container Architecture**
  - Resolved all Docker container networking issues
  - Fixed DNS resolution between containers using IP-based addressing
  - Non-interactive package installations for reliable container builds
  - Proper environment variable handling and configuration templating

### Fixed
- **Critical Container Issues**
  - Fixed Postfix container startup failures due to SASL authentication errors
  - Resolved Dovecot configuration syntax errors preventing service startup
  - Fixed rspamd milter connection failures between containers
  - Eliminated "host/service not found" errors in inter-container communication

- **Docker Infrastructure**
  - Added missing `gettext-base` package to containers requiring envsubst
  - Fixed non-interactive Docker installations preventing build hangs
  - Resolved container restart loops caused by configuration errors
  - Fixed volume permission issues between Postfix and Dovecot containers

- **Email Service Integration**
  - Established working SMTP service with full authentication support
  - Fixed IMAP/POP3 services with proper SQL backend integration
  - Resolved milter protocol communication for spam filtering
  - Fixed container throttling issues after failed connections

### Changed
- **Network Architecture**
  - Migrated from Unix socket authentication to TCP-based SASL for container compatibility
  - Implemented IP-based addressing for reliable inter-container communication
  - Removed problematic shared volume approach in favor of network-based services
  - Improved Docker network isolation and service discovery

- **Configuration Management**
  - Simplified Dovecot configuration for better reliability and maintainability
  - Enhanced Postfix configuration with proper milter and SASL integration
  - Updated rspamd worker configuration for optimal milter protocol support
  - Standardized environment variable usage across all containers

### Technical Improvements
- **Service Reliability**
  - All core email services now fully operational and production-ready
  - Eliminated service startup dependencies causing circular waiting
  - Improved error handling and graceful degradation
  - Enhanced logging and debugging capabilities

- **Performance Optimizations**
  - Redis integration for rspamd caching and improved performance
  - Optimized container resource usage and startup times
  - Reduced memory footprint through configuration optimization
  - Improved database connection pooling and query performance

### Deployment
- **Container Orchestration**
  - All Docker containers now start reliably in correct dependency order
  - Proper health checks and service monitoring implemented
  - Automated environment configuration and secret management
  - Simplified deployment process with single docker-compose command

- **Production Readiness**
  - Full email server functionality with sending and receiving capabilities
  - Complete spam filtering and antivirus integration
  - Web-based management interfaces fully functional
  - Ready for production deployment with proper SSL configuration

### Security
- **Authentication & Authorization**
  - Working SASL authentication for mail client connections
  - Secure inter-service communication protocols
  - Proper credential management and environment variable security
  - Rate limiting and abuse protection mechanisms active

### Documentation
- **Updated Documentation**
  - Comprehensive README with current status and capabilities
  - Detailed changelog tracking all improvements and fixes
  - Updated version information and project status badges
  - Clear installation and setup instructions

## [1.0.1] - 2025-09-23

### Changed
- **Complete Admin Interface Redesign**
  - Replaced React frontend with Django + Bootstrap admin interface
  - Server-side rendering eliminates routing issues
  - Session-based authentication using existing user database
  - Beautiful, responsive Bootstrap 5 UI design
  - Complete user management with CRUD operations
  - Full domain management with user count tracking
  - Settings management with categorized inline editing

### Fixed
- Resolved React Router 404 errors on direct navigation
- Fixed admin interface accessibility and functionality
- Improved error handling and user feedback
- Better mobile responsiveness

### Technical Changes
- Migrated from React/Node.js frontend to Django
- Added Gunicorn + WhiteNoise for production serving
- Integrated with existing PostgreSQL schema using Django ORM
- Added bcrypt compatibility for password hashing
- Docker containerization for Django application

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
  - Django admin interface with Bootstrap UI (replaces React)

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
- **Languages**: JavaScript (Node.js), Python (Django), SQL, Bash
- **Databases**: PostgreSQL 15, Redis 7
- **Email Services**: Postfix 3.x, Dovecot 2.x
- **Security**: Rspamd, ClamAV
- **Frontend**: Django Templates, Bootstrap 5
- **Backend**: Express.js (API), Django (Admin UI), bcrypt
- **Deployment**: Docker, docker-compose
- **Development**: Modern ES6+, async/await patterns, Django ORM

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
- Enhanced Django admin interface with Ajax updates
- Real-time dashboard statistics with WebSocket support
- Advanced user quota management and visualization
- Email queue monitoring interface
- Spam quarantine management with bulk operations
- API documentation with Swagger/OpenAPI
- Two-factor authentication for admin panel
- Improved error handling and logging
- Django REST framework integration

---

*This changelog will be updated with each release to track all changes, improvements, and bug fixes.*
