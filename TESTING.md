# Testing Guide

## Unit Tests

### SDK Tests
```bash
cd sdk
npm test
# Output: 2/2 passing
```

**What's tested:**
- AnnouncerClient input validation
- VaultClient parameter validation
- Buffer size requirements

### Contract Tests
```bash
cd contracts/announcer
cargo test

cd contracts/vault
cargo test
```

**What's tested:**
- Event emission
- Nonce tracking
- Signature verification logic
- Replay attack prevention

## Integration Tests

### Manual End-to-End Flow

**Setup:**
```bash
# Terminal 1: SDK
cd sdk && npm run build -- --watch

# Terminal 2: Relayer
cd relayer && npm start

# Terminal 3: Frontend
cd frontend && npm start
```

**Test Steps:**

1. **Connect Wallet**
   - Open http://localhost:3000
   - Click "Connect Freighter"
   - Verify wallet address shown

2. **Query Nonce**
   - Click "Get Nonce"
   - Should display: "Current nonce: 0"

3. **Test Relayer API**
   ```bash
   # Health check
   curl http://localhost:3000/health
   
   # Query nonce
   curl "http://localhost:3000/nonce/0000000000000000000000000000000000000000000000000000000000000000"
   ```

## Local Testing

### Build Verification

```bash
# Verify all components build
make build

# Check outputs
ls -la sdk/dist/
ls -la relayer/dist/
ls -la frontend/build/
```

### Code Quality

```bash
# Run linters
make lint

# Format code
make fmt

# Check types
cd sdk && npx tsc --noEmit
cd relayer && npx tsc --noEmit
cd frontend && npx tsc --noEmit
```

## Testnet Testing

### 1. Deploy Contracts

```bash
export SOROBAN_ACCOUNT=GXXXXXX...
make deploy-testnet

# Note the contract IDs
```

### 2. Configure Environment

```bash
# Update environment files
cp .env.example .env
# Edit .env with contract IDs

cp relayer/.env.example relayer/.env
# Edit relayer/.env

cp frontend/.env.example frontend/.env.local
# Edit frontend/.env.local
```

### 3. Start Services

```bash
# Terminal 1
cd relayer && npm start

# Terminal 2
cd frontend && npm start
```

### 4. Run End-to-End Test

1. Open http://localhost:3000
2. Connect Freighter wallet
3. Fund account at https://laboratory.stellar.org
4. Click "Get Nonce" - should show "0"
5. Create stealth transaction (manual process)
6. Submit via Relayer
7. Verify on Stellar Expert

### 5. Verify Transactions

```bash
# Check transaction on testnet
https://stellar.expert/explorer/testnet/tx/XXXXX

# Check account
https://stellar.expert/explorer/testnet/account/GXXXXX
```

## Automated Testing

### GitHub Actions

View at: https://github.com/ghost-wallet-protocol/ghost-contracts/actions

**Jobs that run on push:**
1. test-sdk - SDK unit tests
2. build-relayer - Relayer build
3. build-frontend - Frontend build
4. test-contracts - Contract tests
5. lint-contracts - Clippy linting
6. security-audit - Cargo audit

## Performance Testing

### Load Testing Relayer

```bash
# Using Apache Bench
ab -n 1000 -c 10 http://localhost:3000/health

# Using wrk
wrk -t4 -c100 -d30s http://localhost:3000/health
```

### Frontend Performance

```bash
# Generate Lighthouse report
npm install -g lighthouse
lighthouse http://localhost:3000 --view
```

## Security Testing

### Code Audit

```bash
# Rust security audit
cd contracts
cargo audit

# NPM security check
npm audit
```

### Contract Security

1. **Signature Verification**
   - Verify ECDSA Secp256k1 implementation
   - Test with invalid signatures
   - Test signature tampering detection

2. **Nonce Protection**
   - Test replay attack prevention
   - Verify nonce increment
   - Test concurrent withdrawals

3. **Access Control**
   - Verify anyone can call functions
   - No admin/owner checks needed
   - Test with various accounts

## Test Coverage

### SDK

```bash
cd sdk
npm test -- --coverage

# View coverage report
open coverage/lcov-report/index.html
```

### Contracts

```bash
cd contracts/vault
cargo tarpaulin --out Html --output-dir coverage
```

## Continuous Integration

### Local CI Simulation

```bash
# Run everything locally (simulates CI)
chmod +x scripts/build.sh
./scripts/build.sh
```

### Pre-commit Checks

```bash
#!/bin/bash
# .git/hooks/pre-commit

npm run lint || exit 1
npm run build || exit 1
npm test || exit 1
cd contracts && cargo test || exit 1
exit 0
```

## Testing Checklist

- [ ] SDK unit tests passing (2/2)
- [ ] Contract tests passing
- [ ] No lint errors
- [ ] No TypeScript errors
- [ ] Build completes successfully
- [ ] Frontend loads at localhost:3000
- [ ] Relayer starts on localhost:3000
- [ ] Freighter wallet connects
- [ ] Nonce query works
- [ ] Testnet deployment successful
- [ ] End-to-end transaction completes
- [ ] No security audit warnings

## Test Data

### Example Inputs

```typescript
// Stealth pubkey (64 bytes)
const stealthPubkey = Buffer.alloc(64);

// Ephemeral pubkey (64 bytes)
const ephemeralPubkey = Buffer.alloc(64);

// Signature (64 bytes RS format)
const signature = Buffer.alloc(64);

// Message hash (32 bytes)
const messageHash = Buffer.alloc(32);

// View tag
const viewTag = 42;

// Nonce
const nonce = 0n;
```

### Example Contracts

- Testnet Announcer: (After deployment)
- Testnet Vault: (After deployment)
- Mainnet Announcer: (After deployment)
- Mainnet Vault: (After deployment)

## Regression Testing

When making changes, verify:

1. All existing tests still pass
2. No new warnings introduced
3. Build size hasn't increased significantly
4. Performance unchanged
5. API signatures compatible
6. Contract state handling correct

## Bug Reporting

If you find a bug:

1. Reproduce it
2. Note exact steps
3. Include error message
4. Share environment info
5. Create GitHub issue with:
   - Title: Brief description
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Environment (OS, versions)
