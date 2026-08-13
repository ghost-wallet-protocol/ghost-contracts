# Ghost Protocol - Setup & Verification Checklist

This file guides you through validating the scaffolding and moving forward.

## ✅ Project Structure Verification

Run this command to verify all files are in place:

```bash
# Check smart contracts
ls -la contracts/announcer/src/lib.rs
ls -la contracts/vault/src/lib.rs

# Check SDK
ls -la sdk/src/index.ts
ls -la sdk/src/index.test.ts

# Check Relayer
ls -la relayer/src/index.ts
ls -la relayer/README.md

# Check Frontend
ls -la frontend/src/App.tsx
ls -la frontend/public/index.html

# Check build tools
ls -la Makefile
ls -la scripts/build.sh
ls -la scripts/deploy.sh
ls -la .github/workflows/ci.yml

# Check documentation
ls -la README.md
ls -la PRODUCTION.md
ls -la INTEGRATION.md
```

## 📋 Setup Checklist

### Phase 1: Environment Setup

- [ ] **Install Rust**
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  ```

- [ ] **Install Node.js** (18+)
  ```bash
  node --version  # Should show v18 or higher
  npm --version   # Should show 9 or higher
  ```

- [ ] **Install soroban-cli**
  ```bash
  make install-tools
  # Or manually:
  cargo install soroban-cli --locked
  ```

- [ ] **Add WASM target**
  ```bash
  rustup target add wasm32-unknown-unknown
  ```

### Phase 2: Build Verification

- [ ] **Build Smart Contracts**
  ```bash
  cd contracts/announcer && cargo check && cd ../..
  cd contracts/vault && cargo check && cd ../..
  ```

- [ ] **Build SDK**
  ```bash
  cd sdk && npm install && npm run build && cd ..
  ```

- [ ] **Build Relayer**
  ```bash
  cd relayer && npm install && npm run build && cd ..
  ```

- [ ] **Build Frontend**
  ```bash
  cd frontend && npm install && npm run build && cd ..
  ```

- [ ] **Run All Tests**
  ```bash
  make test
  ```

### Phase 3: Development Setup

- [ ] **Create .env files from examples**
  ```bash
  cp relayer/.env.example relayer/.env
  cp frontend/.env.example frontend/.env.local
  ```

- [ ] **Configure environment variables**
  ```bash
  # Edit files and set:
  # relayer/.env:
  #   SOROBAN_RPC_URL=https://soroban-testnet.stellar.org
  #   VAULT_CONTRACT_ID=<after deployment>
  #   RELAYER_SECRET_KEY=<your secret key>
  #
  # frontend/.env.local:
  #   REACT_APP_VAULT_CONTRACT_ID=<after deployment>
  #   REACT_APP_ANNOUNCER_CONTRACT_ID=<after deployment>
  ```

- [ ] **Test development mode**
  ```bash
  # Terminal 1
  make dev-sdk
  
  # Terminal 2 (in another session)
  make dev-relayer
  
  # Terminal 3 (in another session)
  make dev-frontend
  
  # Open http://localhost:3000
  ```

### Phase 4: Contract Deployment

- [ ] **Set your Soroban account**
  ```bash
  export SOROBAN_ACCOUNT=G<your-public-key>
  # Get your public key: soroban config identity show default
  ```

- [ ] **Deploy to Testnet**
  ```bash
  make deploy-testnet
  
  # Save the output:
  # Announcer Contract ID: CABC...
  # Vault Contract ID: CABC...
  ```

- [ ] **Update environment files**
  ```bash
  # Edit relayer/.env and frontend/.env.local with contract IDs
  VAULT_CONTRACT_ID=CABC...123
  ANNOUNCER_CONTRACT_ID=CABC...456
  ```

- [ ] **Verify contracts on Testnet**
  ```bash
  # Check Testnet Explorer: https://stellar.expert/explorer/testnet
  # Search for your contract IDs
  ```

### Phase 5: Integration Testing

- [ ] **Test Relayer Endpoints**
  ```bash
  # Start relayer first
  cd relayer && npm run dev
  
  # In another terminal, test:
  curl http://localhost:3000/health
  
  curl "http://localhost:3000/nonce/0000000000000000000000000000000000000000000000000000000000000000"
  ```

- [ ] **Test Frontend Integration**
  ```bash
  # Start frontend
  make dev-frontend
  
  # Open http://localhost:3000
  # Click "Connect Freighter"
  # Test "Get Nonce" button
  ```

- [ ] **SDK Type Safety**
  ```bash
  # Verify TypeScript types
  cd sdk && npm run build -- --noEmit
  ```

### Phase 6: Code Quality

- [ ] **Run Linters**
  ```bash
  make lint
  ```

- [ ] **Format Code**
  ```bash
  make fmt
  ```

- [ ] **Security Audit**
  ```bash
  cd contracts && cargo audit && cd ..
  ```

### Phase 7: Production Preparation

- [ ] **Review PRODUCTION.md**
  - [ ] Understand architecture
  - [ ] Review security checklist
  - [ ] Plan deployment strategy

- [ ] **Review INTEGRATION.md**
  - [ ] Understand SDK integration patterns
  - [ ] Plan npm publishing strategy

- [ ] **Update Documentation**
  - [ ] Replace placeholder URLs
  - [ ] Add your repository information
  - [ ] Add support links

- [ ] **Create GitHub Repository**
  ```bash
  # Create repo at github.com/your-org/ghost-contracts
  git remote add origin https://github.com/your-org/ghost-contracts
  git push -u origin main
  ```

- [ ] **Configure GitHub Secrets** (for CI/CD)
  - [ ] Add `GITHUB_TOKEN` for package publishing
  - [ ] Update CI/CD pipeline for your org

### Phase 8: Mainnet Preparation

- [ ] **Testnet Validation**
  - [ ] Full end-to-end flow works
  - [ ] All transactions succeed
  - [ ] No errors in logs

- [ ] **Security Review**
  - [ ] Code audit complete
  - [ ] No cargo audit warnings
  - [ ] Relayer secret key management reviewed

- [ ] **Deployment Plan**
  ```bash
  # Mainnet deployment command
  export SOROBAN_ACCOUNT=G<mainnet-public-key>
  make deploy-mainnet
  ```

## 📝 Customization Checklist

### Smart Contracts

- [ ] Review `contracts/announcer/src/lib.rs`
  - [ ] Adjust event fields if needed
  - [ ] Add additional validation

- [ ] Review `contracts/vault/src/lib.rs`
  - [ ] Adjust withdrawal logic
  - [ ] Add additional security checks
  - [ ] Customize fee handling if needed

### SDK

- [ ] Update `sdk/src/index.ts`
  - [ ] Add contract ABI bindings (from soroban-sdk)
  - [ ] Implement contract invocation methods
  - [ ] Add cryptography helpers

### Relayer

- [ ] Customize `relayer/src/index.ts`
  - [ ] Add rate limiting
  - [ ] Add request logging/monitoring
  - [ ] Add additional validation
  - [ ] Add fee estimation logic

### Frontend

- [ ] Customize `frontend/src/App.tsx`
  - [ ] Add stealth address generation UI
  - [ ] Add transaction signing interface
  - [ ] Add amount input and validation
  - [ ] Add transaction history display

## 🚀 Deployment Checklist

### Before Deploying to Testnet

- [ ] Build succeeds: `make build`
- [ ] Tests pass: `make test`
- [ ] No lint errors: `make lint`
- [ ] No audit issues: `cargo audit`

### Before Deploying to Mainnet

- [ ] ✅ Testnet deployment successful
- [ ] ✅ Thorough testnet testing completed
- [ ] ✅ Security review completed
- [ ] ✅ Code audit completed
- [ ] ✅ Team approval obtained
- [ ] ✅ Backup plan documented
- [ ] ✅ Monitoring configured
- [ ] ✅ Runbook created for incidents

## 📚 Documentation Checklist

Files you've been given:

- [x] **README.md** - Quick start guide
- [x] **PRODUCTION.md** - Complete production guide
- [x] **INTEGRATION.md** - SDK integration patterns
- [x] **SCAFFOLDING.md** - This scaffolding summary
- [x] **relayer/README.md** - Relayer API documentation
- [x] **Makefile** - Self-documenting commands

Additional documentation to create:

- [ ] **ARCHITECTURE.md** - Detailed system design
- [ ] **API.md** - Complete API reference
- [ ] **TESTING.md** - Testing strategies and examples
- [ ] **SECURITY.md** - Security analysis and mitigations
- [ ] **DEPLOYMENT.md** - Deployment runbooks
- [ ] **TROUBLESHOOTING.md** - Common issues and solutions

## 🎯 Success Criteria

You'll know the scaffolding is complete when:

- ✅ All files and directories are in place
- ✅ Smart contracts compile without errors
- ✅ SDK TypeScript compiles without errors
- ✅ Relayer starts on http://localhost:3000
- ✅ Frontend starts on http://localhost:3000 (separate port)
- ✅ All unit tests pass
- ✅ No linting errors
- ✅ No cargo audit warnings
- ✅ Contracts deploy to testnet successfully
- ✅ Frontend can query nonce from relayer

## 🔗 Important Links

### Development
- **Makefile**: See all commands with `make help`
- **GitHub Actions**: Edit `.github/workflows/ci.yml` for CI/CD

### Documentation
- **Production Guide**: Read `PRODUCTION.md` for deployment details
- **Integration Guide**: Read `INTEGRATION.md` for SDK integration

### Stellar Resources
- **Soroban Docs**: https://developers.stellar.org/learn/soroban
- **Testnet Explorer**: https://stellar.expert/explorer/testnet
- **Mainnet Explorer**: https://stellar.expert/explorer
- **Freighter Wallet**: https://www.freighter.app

## 💬 Getting Help

1. **Check the documentation**
   - README.md - Quick answers
   - PRODUCTION.md - Detailed guidance
   - INTEGRATION.md - SDK patterns

2. **Review existing examples**
   - SDK has example clients
   - Relayer has example server
   - Frontend has example UI

3. **Consult Stellar docs**
   - https://developers.stellar.org
   - Soroban API reference
   - RPC documentation

## ✨ Next Steps

1. Run the checklist above to verify everything
2. Customize contracts for your use case
3. Deploy to testnet and test end-to-end
4. Integrate with your existing frontend/backend
5. Deploy to mainnet when ready

---

**Last Updated:** August 13, 2026
**Status:** Production-ready scaffolding ✅
