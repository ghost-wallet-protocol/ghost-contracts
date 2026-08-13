# Troubleshooting Guide

## Build Issues

### "cargo: command not found"
**Problem:** Rust not installed  
**Solution:**
```bash
make install-tools
# Or manually:
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### "wasm32-unknown-unknown target not found"
**Problem:** WASM target not installed  
**Solution:**
```bash
rustup target add wasm32-unknown-unknown
```

### "npm ERR! code ERESOLVE"
**Problem:** Dependency conflict  
**Solution:**
```bash
# Clear and reinstall
rm -rf node_modules package-lock.json
npm install
```

### "TypeError: Cannot find module"
**Problem:** Module not installed  
**Solution:**
```bash
# In the specific directory
cd sdk && npm install && cd ..
```

## Runtime Issues

### "Port 3000 already in use"
**Problem:** Another service using port 3000  
**Solution:**
```bash
# Option 1: Kill existing process
lsof -i :3000  # Find process
kill -9 <PID>

# Option 2: Use different port
PORT=3001 make dev-frontend
```

### "Contract not found: CABC..."
**Problem:** Contract ID incorrect or not deployed  
**Solution:**
```bash
# Check contract ID
echo $VAULT_CONTRACT_ID

# Redeploy if needed
export SOROBAN_ACCOUNT=G...
make deploy-testnet
```

### "Invalid signature"
**Problem:** Signature doesn't match stealth key  
**Solution:**
- Verify you're signing with correct stealth key
- Check message hash is correct (recipient + nonce)
- Use proper ECDSA Secp256k1 signing algorithm

### "Nonce already used"
**Problem:** Trying to use same nonce twice  
**Solution:**
```bash
# Query fresh nonce
curl "http://localhost:3000/nonce/$PUBKEY"

# Include new nonce in next withdrawal
```

## Network Issues

### "RPC connection failed"
**Problem:** Can't reach Soroban RPC  
**Solution:**
```bash
# Test RPC endpoint
curl https://soroban-testnet.stellar.org/health

# Update RPC URL if needed
export SOROBAN_RPC_URL=https://soroban-testnet.stellar.org
```

### "Transaction timeout"
**Problem:** Transaction taking too long  
**Solution:**
- Wait longer (Stellar consensus ~5-10s)
- Check network status at https://stellar.expert
- Retry with fresh nonce

### "Fee too low"
**Problem:** Gas price increased  
**Solution:**
- Relayer handles fees automatically
- May need to top up relayer account

## Frontend Issues

### "Freighter not detected"
**Problem:** Wallet extension not installed  
**Solution:**
1. Install Freighter: https://www.freighter.app
2. Set network to Testnet
3. Create or import account

### "Blank screen on localhost:3000"
**Problem:** Frontend failed to build  
**Solution:**
```bash
cd frontend
npm install
npm run build
npm start
```

### "TypeError: Cannot read property 'getPublicKey'"
**Problem:** Freighter not accessible  
**Solution:**
```typescript
// Check if Freighter is available
const isAllowed = await freighter.isAllowed();
if (!isAllowed) {
  console.error('Freighter not installed');
}
```

## SDK Issues

### "Module '@ghost-protocol/sdk' not found"
**Problem:** SDK not installed or linked  
**Solution:**
```bash
# For development (local linking)
cd sdk && npm link
cd ../frontend && npm link @ghost-protocol/sdk

# For production
npm install @ghost-protocol/sdk
```

### "TypeScript error: Property 'X' does not exist"
**Problem:** SDK types not generated  
**Solution:**
```bash
cd sdk
npm run build  # Generates dist/ and types
```

## Relayer Issues

### "Relayer won't start: ENOENT"
**Problem:** Missing environment variables  
**Solution:**
```bash
# Create .env file
cp relayer/.env.example relayer/.env

# Edit and fill in values
export VAULT_CONTRACT_ID=CABC...
export RELAYER_SECRET_KEY=S...
npm start
```

### "Error: VAULT_CONTRACT_ID is required"
**Problem:** Environment variable not set  
**Solution:**
```bash
export VAULT_CONTRACT_ID=CABC...
export RELAYER_SECRET_KEY=S...
npm start
```

### "POST /withdraw fails"
**Problem:** Invalid request format  
**Solution:**
```typescript
// Verify all fields are present and correct format
{
  tokenAddress: string;        // Contract address
  stealthPubkey: string;       // 128 hex chars (64 bytes)
  signature: string;           // 128 hex chars (64 bytes)
  recoveryId: number;          // 0-3
  messageHash: string;         // 64 hex chars (32 bytes)
  recipient: string;           // Account address
  amount: string;              // Numeric string
}
```

## Contract Issues

### "Contract doesn't compile"
**Problem:** Rust syntax or Soroban API error  
**Solution:**
```bash
cd contracts/vault
cargo check  # Check for errors
cargo clippy # Lint
```

### "Test failure: assertion failed"
**Problem:** Unit test failed  
**Solution:**
```bash
cd contracts/vault
cargo test -- --nocapture  # Show output
```

## CI/CD Issues

### "GitHub Actions failing"
**Problem:** CI pipeline error  
**Solution:**
1. Check build log in Actions tab
2. Common issues:
   - Rust not installing: Check rust-toolchain step
   - npm ci failing: Change to npm install
   - Linting: Remove strict linting rules

### "Build artifacts not uploading"
**Problem:** Path incorrect  
**Solution:**
```yaml
# Check .github/workflows/ci.yml has correct paths
- uses: actions/upload-artifact@v3
  with:
    path: |
      sdk/dist/
      relayer/dist/
      frontend/build/
```

## General Debugging

### Enable verbose output

```bash
# Rust
RUST_LOG=debug cargo build

# Node/npm
npm install --verbose

# Frontend
REACT_APP_DEBUG=true npm start
```

### Check logs

```bash
# Relayer
tail -f relayer/logs.txt

# Frontend (browser console)
# Open DevTools (F12)
# Check Console tab

# Contracts
# Check Stellar Expert
# https://stellar.expert/explorer/testnet
```

### Get system info

```bash
# Rust version
rustc --version
cargo --version

# Node version
node --version
npm --version

# System info
uname -a
```

## Still Having Issues?

1. Check documentation: PRODUCTION.md, INTEGRATION.md
2. Review code examples: EXAMPLES.md
3. Check API reference: API_REFERENCE.md
4. Review architecture: ARCHITECTURE.md
5. Open GitHub issue with:
   - Error message (full output)
   - Steps to reproduce
   - Environment info (OS, versions)
   - What you tried to fix it
