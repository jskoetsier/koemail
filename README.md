# KoeMail - Complete Email Server Solution

A comprehensive, self-hosted email server with modern web interfaces, built with industry-standard components.

## Architecture

### Core Components
- **Postfix**: SMTP service for email delivery
- **Dovecot**: IMAP/POP3 service for email access
- **PostgreSQL**: Database for users, domains, and configuration
- **Rspamd**: Advanced spam filtering
- **ClamAV**: Antivirus scanning
- **RainLoop**: Modern webmail client with clean interface

### Management Interfaces
- **Admin UI**: React-based single-page application for server management
- **Webmail**: RainLoop-powered interface for end users
- **API**: RESTful API for programmatic access

## Features

### Administration
- User management (create, edit, delete users)
- Domain and alias management
- Quota management with visual indicators
- Server monitoring (disk usage, queue size, etc.)
- Security settings and spam/AV configuration

### End User Features
- Modern webmail interface (Outlook-like experience)
- Email management (compose, send, receive, organize)
- Contact management and address book
- Shared calendars for collaboration
- Spam quarantine management
- Personal spam/ham reporting

### Security
- Comprehensive spam filtering with Rspamd
- Antivirus scanning with ClamAV
- User-controlled spam quarantine
- Secure authentication and encryption
- Rate limiting and abuse protection

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
├── admin-ui/              # React admin interface
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
