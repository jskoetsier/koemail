# KoeMail - Complete Email Server Solution

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![Status](https://img.shields.io/badge/status-stable-green.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

A comprehensive, production-ready self-hosted email server with modern web interfaces, built with industry-standard components and full Docker orchestration.

## 🚀 Current Status (v1.1.0) - Fully Operational

**All core email services are working and production-ready:**

- ✅ **SMTP Service**: Full email sending/receiving with SASL authentication
- ✅ **IMAP/POP3**: Email access with secure authentication
- ✅ **Spam Filtering**: Advanced rspamd integration with milter protocol
- ✅ **Antivirus**: ClamAV integration for malware protection
- ✅ **Webmail**: Modern RainLoop interface for end users
- ✅ **Admin Panel**: Complete Django-based management interface
- ✅ **Database**: PostgreSQL with comprehensive schema
- ✅ **Container Orchestration**: Docker Compose with proper networking

## Architecture

### Core Components
- **Postfix**: SMTP service for email delivery with PostgreSQL backend
- **Dovecot**: IMAP/POP3 service with SQL authentication and SASL support
- **PostgreSQL**: Database for users, domains, aliases, and configuration
- **Rspamd**: Advanced spam filtering with Redis backend and milter integration
- **ClamAV**: Real-time antivirus scanning for email attachments
- **RainLoop**: Modern responsive webmail client
- **Redis**: High-performance caching for rspamd and session storage

### Management Interfaces
- **Admin UI**: Django-based admin interface with Bootstrap 5 UI
- **Webmail**: RainLoop-powered interface for end users (port 8080)
- **API**: RESTful API for programmatic access (port 8000)

## Features

### Administration
- Complete user management (create, edit, delete, quotas)
- Virtual domain and alias management
- Real-time server monitoring and statistics
- Spam/antivirus configuration and reporting
- Security settings and access control
- Django admin interface with modern Bootstrap UI

### End User Features
- Modern responsive webmail interface
- Full email management (compose, send, receive, organize)
- Contact management and address book
- Advanced search and filtering
- Mobile-friendly responsive design
- Spam quarantine management

### Security & Performance
- **Authentication**: SASL authentication between Postfix and Dovecot
- **Spam Protection**: Advanced rspamd filtering with custom rules
- **Virus Protection**: Real-time ClamAV scanning
- **Encryption**: TLS/SSL support for all protocols
- **Rate Limiting**: Built-in abuse protection
- **Performance**: Redis caching and optimized PostgreSQL queries

## Quick Start

```bash
# Clone and start the entire stack
git clone <repo-url>
cd koemail
docker-compose up -d

# Access interfaces
# Admin UI: http://localhost:3000
# Webmail: http://localhost:8080
# API: http://localhost:8000
```

## Project Structure

```
koemail/
├── docker/                 # Docker configurations
│   ├── postfix/            # Postfix SMTP server
│   ├── dovecot/            # Dovecot IMAP/POP3 server
│   ├── postgresql/         # Database setup
│   ├── rspamd/            # Spam filtering
│   ├── clamav/            # Antivirus
│   └── rainloop/          # Webmail client
├── admin-ui/              # Django admin interface
├── api/                   # Backend API service
├── scripts/               # Utility scripts
└── docker-compose.yml     # Orchestration
```

## Development

See individual component READMEs for detailed setup instructions. For contributing guidelines, please read [CONTRIBUTING.md](CONTRIBUTING.md).

## Versioning

This project uses [Semantic Versioning](https://semver.org/). See [VERSION](VERSION) file for current version and [CHANGELOG.md](CHANGELOG.md) for release history.

## Roadmap

See our [ROADMAP.md](ROADMAP.md) for planned features and development timeline.

## License

MIT License
