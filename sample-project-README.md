# Sample Node.js Project for CI/CD Dashboard Testing

This is a minimal Node.js project for testing the CI/CD pipeline with Jenkins.

## Quick Start

```bash
npm install
npm test
npm run build
```

## Available Scripts

- `npm install` - Install dependencies
- `npm test` - Run tests
- `npm run build` - Build project
- `npm run lint` - Run linter
- `npm start` - Start application

## CI/CD Integration

This project includes a `Jenkinsfile` that defines the CI/CD pipeline:

1. Checkout code
2. Install dependencies
3. Build
4. Test
5. Lint
6. Security scan
7. Package
8. Deploy (main branch only)

## GitHub Setup

1. Create a new GitHub repository
2. Copy all files from this project to your repo
3. Push to GitHub:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO.git
git push -u origin main
```

4. Configure Jenkins to watch your repository (see JENKINS.md)

## Dashboard Integration

The Jenkinsfile automatically sends updates to the CI/CD Dashboard at:
- http://localhost:3000

Watch your builds in real-time!

## Requirements

- Node.js 20+
- npm 9+
