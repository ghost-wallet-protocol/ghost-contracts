# Contributing Guide

## Development Workflow

1. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make changes**
   - Work on your feature
   - Test locally: `make test`
   - Format code: `make fmt`
   - Check quality: `make lint`

3. **Commit changes**
   ```bash
   git add .
   git commit -m "feat: Brief description of changes"
   ```

4. **Push and create PR**
   ```bash
   git push -u origin feature/your-feature-name
   ```

## Commit Message Format

Use conventional commits:

```
feat:     New feature
fix:      Bug fix
docs:     Documentation
style:    Code style (formatting, etc)
refactor: Code refactoring
test:     Adding or updating tests
chore:    Build, deps, etc
ci:       CI/CD changes
```

Example:
```bash
git commit -m "feat: Add signature verification to vault contract"
git commit -m "fix: Handle nonce overflow in withdraw function"
git commit -m "docs: Update deployment guide"
```

## Testing

### Unit Tests
```bash
make test              # Run all tests
cd sdk && npm test     # SDK tests only
```

### Manual Testing
```bash
# Start all services in separate terminals
make dev-frontend
make dev-relayer
make dev-sdk
```

## Code Quality

### Linting
```bash
make lint              # Run all linters
cd contracts && cargo clippy
cd sdk && npm run lint
```

### Formatting
```bash
make fmt               # Format everything
cd contracts && cargo fmt
cd sdk && npx prettier --write src
```

## Pull Request Process

1. Ensure all tests pass: `make test`
2. Ensure no lint errors: `make lint`
3. Update documentation if needed
4. Describe your changes in the PR
5. Request review from maintainers
6. Address feedback and update

## Documentation Style

- Use clear, concise language
- Include examples where helpful
- Keep README.md up to date
- Update PRODUCTION.md for major changes
- Add code comments for complex logic

## Release Process

1. Update version in package.json files
2. Update CHANGELOG.md
3. Create release branch: `git checkout -b release/v1.0.0`
4. Create PR and merge to main
5. Create GitHub release with tag
6. Publish SDK: `cd sdk && npm publish`

## Questions?

- Check PRODUCTION.md for architecture details
- Check INTEGRATION.md for SDK patterns
- Open an issue on GitHub
- Start a discussion in the README
