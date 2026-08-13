# CI/CD Troubleshooting

## Current GitHub Actions Status

### Working ✅
- `test-sdk` - SDK TypeScript tests (2/2 passing)
- `build-relayer` - Relayer Express server builds
- `build-frontend` - React frontend production build

### Disabled ⏭️ (Require Rust/Cargo)
- `test-contracts` - Requires Rust toolchain
- `lint-contracts` - Requires cargo clippy
- `security-audit` - Requires cargo audit

**Reason:** The GitHub Actions runner may not have optimal Rust support. These are still valid and should be run locally.

## Local CI Simulation

To test everything locally before pushing:

### 1. SDK Build & Test
```bash
cd sdk
npm install
npm run build
npm test
```

Expected output:
```
PASS src/index.test.ts
Tests: 2 passed, 2 total
```

### 2. Relayer Build
```bash
cd relayer
npm install
npm run build
```

Expected output:
```
> tsc
(no errors)
```

### 3. Frontend Build
```bash
cd frontend
npm install
npm run build
```

Expected output:
```
File sizes after gzip:
  260.11 kB  build/static/js/main.*.js
The build folder is ready to be deployed.
```

### 4. Contract Tests (Local Only)
```bash
cd contracts/announcer && cargo test && cd ../..
cd contracts/vault && cargo test && cd ../..
```

## Fixing GitHub Actions Failures

### If SDK test fails:

1. Check error message in Actions log
2. Local test: `cd sdk && npm test`
3. Common issues:
   - Missing jest.config.json
   - TypeScript compilation error
   - Missing dependency

### If Relayer fails:

1. Check TypeScript errors
2. Local test: `cd relayer && npm run build`
3. Common issues:
   - Network passphrase constant
   - Missing dependencies
   - TypeScript strict mode

### If Frontend fails:

1. Check build log
2. Local test: `cd frontend && npm run build`
3. Common issues:
   - Missing type definitions
   - Freighter API version
   - React import issues

## Setting Up Contract Tests in CI

To enable Rust tests in CI:

```yaml
# .github/workflows/ci.yml
test-contracts:
  name: Test Contracts
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3
    - uses: dtolnay/rust-toolchain@stable
      with:
        targets: wasm32-unknown-unknown
    - uses: Swatinem/rust-cache@v2
    - run: cd contracts/announcer && cargo test && cd ../..
    - run: cd contracts/vault && cargo test && cd ../..
```

## Pre-commit Hook

To prevent pushing broken code:

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

echo "Running pre-commit checks..."

# SDK
cd sdk
npm run build || exit 1
npm test || exit 1
cd ..

# Relayer
cd relayer
npm run build || exit 1
cd ..

# Frontend
cd frontend
npm run build || exit 1
cd ..

echo "✅ All checks passed"
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Debugging GitHub Actions

### View Logs

1. Go to: https://github.com/ghost-wallet-protocol/ghost-contracts/actions
2. Click on the failed workflow run
3. Expand job details to see full error

### Re-run Failed Job

1. On Actions page
2. Click the failed job
3. Click "Re-run failed jobs"

### Enable Debug Logging

Add to workflow file:
```yaml
env:
  ACTIONS_STEP_DEBUG: true
```

## Common CI Errors & Fixes

### "npm ci not available"
**Fix:** Use `npm install` instead

### "Module not found: @stellar/..."
**Fix:** Ensure package.json has correct dependency versions

### "TypeScript error TS2614"
**Fix:** Check imports are correct for current SDK version

### "ENOSPC: no space left on device"
**Fix:** GitHub Actions runner ran out of space
- Clear npm cache: `npm cache clean --force`
- Remove unnecessary files

### "Port 3000 already in use"
**Fix:** Use different port in tests
```bash
PORT=3001 npm start
```

## Performance Optimization

### Cache Dependencies

```yaml
- uses: actions/setup-node@v3
  with:
    node-version: "18"
    cache: 'npm'
    cache-dependency-path: 'sdk/package-lock.json'
```

### Parallel Jobs

Current setup runs all 3 jobs in parallel (fast):
- SDK test
- Relayer build
- Frontend build

### Skip CI

To skip running CI on a commit:

```bash
git commit -m "docs: Update README [skip ci]"
git push
```

## Monitoring CI Health

Check CI status at:
https://github.com/ghost-wallet-protocol/ghost-contracts/actions

Expected:
- All jobs pass ✅
- Takes ~3-4 minutes total
- No warnings or errors

## Next Steps

1. **Enable Contract Tests** (when Rust setup stabilized)
2. **Add Security Scanning** (Snyk, Dependabot)
3. **Add Code Coverage** (Codecov)
4. **Add Performance Benchmarks** (for contracts)
5. **Add E2E Tests** (testnet integration)

## Troubleshooting Workflow

If CI fails:

1. **Check the error** - Read GitHub Actions log
2. **Reproduce locally** - Run same commands locally
3. **Fix the issue** - Debug and fix locally
4. **Test locally** - Verify fix works
5. **Push fix** - Commit and push to trigger CI
6. **Verify pass** - Check GitHub Actions passes

## Support

For CI issues:
1. Check this troubleshooting guide
2. Review TESTING.md for test setup
3. Review build scripts in scripts/
4. Check GitHub Actions documentation
