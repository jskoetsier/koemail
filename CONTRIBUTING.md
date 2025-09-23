# Contributing to KoeMail

We welcome contributions to KoeMail! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Respect differing viewpoints and experiences
- Show empathy towards other community members

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/koemail.git
   cd koemail
   ```
3. **Set up the development environment** (see below)
4. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- Docker and Docker Compose
- Node.js 16+ (for local development)
- Git

### Local Development

1. **Copy environment configuration:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` file** with your local settings

3. **Start the development stack:**
   ```bash
   ./scripts/setup.sh
   ```

4. **Access services:**
   - Admin UI: http://localhost:3000
   - Webmail: http://localhost:8080
   - API: http://localhost:8000

### Development Workflow

For **API development:**
```bash
cd api
npm install
npm run dev  # Start with nodemon for auto-reload
```

For **Admin UI development:**
```bash
cd admin-ui
npm install
npm start    # Start React development server
```

## Making Changes

### Types of Contributions

- **Bug fixes** - Fix issues in existing functionality
- **Features** - Add new functionality (check roadmap first)
- **Documentation** - Improve docs, comments, examples
- **Testing** - Add or improve tests
- **Performance** - Optimize existing code
- **Security** - Fix security vulnerabilities

### Before You Start

1. **Check existing issues** to avoid duplicate work
2. **Create an issue** for new features or major changes
3. **Discuss your approach** with maintainers if needed
4. **Follow the roadmap** for planned features

### Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(api): add user bulk operations endpoint
fix(webmail): resolve login redirect issue
docs(readme): update installation instructions
```

## Pull Request Process

1. **Update documentation** if needed
2. **Add or update tests** for your changes
3. **Ensure all tests pass**
4. **Update CHANGELOG.md** if your change affects users
5. **Create the pull request** with:
   - Clear title describing the change
   - Detailed description of what you changed and why
   - Link to related issues
   - Screenshots for UI changes

### Pull Request Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## How Has This Been Tested?
Describe the tests that you ran to verify your changes

## Checklist:
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
```

## Coding Standards

### JavaScript/Node.js
- Use ES6+ features
- Use async/await instead of callbacks
- Follow ESLint configuration
- Use meaningful variable and function names
- Add JSDoc comments for complex functions

### React
- Use functional components with hooks
- Follow React best practices
- Use meaningful component names
- Add PropTypes for props validation

### Docker
- Use multi-stage builds where appropriate
- Minimize image size
- Use specific version tags, not `latest`
- Add health checks to services

### Database
- Use migrations for schema changes
- Follow PostgreSQL naming conventions
- Add proper indexes for performance
- Include down migrations

### API Design
- Follow RESTful principles
- Use appropriate HTTP status codes
- Validate input data
- Provide consistent error responses
- Document endpoints

## Testing

### Running Tests

```bash
# API tests
cd api
npm test

# Admin UI tests
cd admin-ui
npm test

# Integration tests
docker compose -f docker-compose.test.yml up --abort-on-container-exit
```

### Test Guidelines

- **Unit tests** for individual functions
- **Integration tests** for API endpoints
- **E2E tests** for critical user flows
- **Aim for >80% code coverage**
- **Test both success and error cases**

### Test Structure

```javascript
describe('Feature Name', () => {
  beforeEach(() => {
    // Setup
  });

  afterEach(() => {
    // Cleanup
  });

  it('should do something specific', async () => {
    // Arrange
    const input = 'test data';
    
    // Act
    const result = await functionUnderTest(input);
    
    // Assert
    expect(result).toBe('expected output');
  });
});
```

## Documentation

### Types of Documentation

- **README.md** - Project overview and quick start
- **API documentation** - Endpoint specifications
- **User guides** - How to use features
- **Admin guides** - Installation and configuration
- **Code comments** - Inline documentation

### Documentation Guidelines

- **Use clear, simple language**
- **Include examples** where helpful
- **Keep it up to date** with code changes
- **Use consistent formatting**
- **Test instructions** to ensure they work

### API Documentation

Use JSDoc comments for API endpoints:

```javascript
/**
 * Create a new user
 * @route POST /api/users
 * @param {Object} req.body - User data
 * @param {string} req.body.email - User email
 * @param {string} req.body.password - User password
 * @returns {Object} Created user object
 */
```

## Release Process

1. **Update version** in `VERSION` file and `package.json`
2. **Update CHANGELOG.md** with new version
3. **Create release tag:**
   ```bash
   git tag -a v1.1.0 -m "Release version 1.1.0"
   git push origin v1.1.0
   ```
4. **Create GitHub release** with changelog notes

## Getting Help

- **GitHub Issues** - For bugs and feature requests
- **GitHub Discussions** - For questions and ideas
- **Documentation** - Check existing docs first
- **Code Review** - Ask for feedback on complex changes

## Recognition

Contributors will be acknowledged in:
- CHANGELOG.md for their contributions
- GitHub contributor list
- Annual contributor spotlight (planned)

Thank you for contributing to KoeMail! 🚀