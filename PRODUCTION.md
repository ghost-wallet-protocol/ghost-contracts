# Ghost Protocol - Production Documentation

## Overview

Ghost Protocol is a stealth transaction system built on Stellar's Soroban smart contracts. It enables users to send and receive funds privately through stealth addresses and ephemeral keys.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Frontend (React)                            │
│         - Stealth address generation & key management           │
│         - Transaction signing with Freighter wallet             │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                    ┌──────────┴───────────┐
                    │                      │
        ┌───────────▼────────────┐  ┌─────▼──────────────┐
        │  SDK (@ghost-protocol) │  │  Relayer Backend   │
        │  - Contract clients    │  │  - Fee bumping     │
        │  - Type-safe API       │  │  - Transaction mgmt│
        └───────────┬────────────┘  └─────┬──────────────┘
                    │                      │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼────────────┐
                    │  Soroban Contracts   │
                    │  ┌──────────────────┤
                    │  │ Announcer        │
                    │  │ - Event emission │
                    │  └──────────────────┤
                    │  │ Vault            │
                    │  │ - Fund storage   │
                    │  │ - Verification   │
                    │  └──────────────────┤
                    └─────────────────────┘
                               │
                    ┌──────────▼────────────┐
                    │  Stellar Blockchain  │
                    └─────────────────────┘
```

## Project Structure

```
ghost-contracts/
├── contracts/                    # Soroban smart contracts
│   ├── announcer/               # Event announcer contract
│   │   ├── src/lib.rs          # Main contract code
│   │   └── Cargo.toml          # Rust manifest
│   └── vault/                   # Stealth withdrawal contract
│       ├── src/lib.rs          # Main contract code
│       └── Cargo.toml          # Rust manifest
│
├── sdk/                         # TypeScript SDK
│   ├── src/
│   │   ├── index.ts            # Main SDK exports
│   │   └── index.test.ts       # SDK tests
│   ├── package.json
│   └── tsconfig.json
│
├── relayer/                     # Backend relayer server
│   ├── src/
│   │   └── index.ts            # Express server
│   ├── package.json
│   └── tsconfig.json
│
├── frontend/                    # React frontend
│   ├── src/
│   │   ├── App.tsx             # Main app component
│   │   ├── App.css             # Styles
│   │   ├── index.tsx           # Entry point
│   │   └── index.html          # HTML template
│   ├── public/
│   └── package.json
│
├── scripts/                     # Build and deployment scripts
│   ├── build.sh                # Build all projects
│   └── deploy.sh               # Deploy contracts
│
├── .github/
│   └── workflows/
│       └── ci.yml              # GitHub Actions CI/CD
│
├── Cargo.toml                  # Rust workspace root
├── Makefile                    # Development commands
└── README.md                   # This file
```

## Development Setup

### Prerequisites

- Rust 1.70+
- Node.js 18+
- npm 9+
- soroban-cli

### Quick Start

1. **Install Tools**
   ```bash
   make install-tools
   ```

2. **Build Everything**
   ```bash
   make build
   ```

3. **Run Tests**
   ```bash
   make test
   ```

4. **Development Mode**
   ```bash
   # Terminal 1: Watch SDK changes
   make dev-sdk
   
   # Terminal 2: Start relayer
   make dev-relayer
   
   # Terminal 3: Start frontend
   make dev-frontend
   ```

## Contract Specifications

### Announcer Contract

**Purpose:** Broadcast stealth transfer announcements on-chain for client-side indexing

**Functions:**
- `announce(env, stealth_address, ephemeral_pubkey, view_tag, metadata)` - Emit announcement event

**Events:**
```
Topic: ("announce", stealth_address)
Data: (ephemeral_pubkey, view_tag, metadata)
```

### Vault Contract

**Purpose:** Store and release funds based on stealth key ECDSA signatures

**Functions:**
- `deposit(env, token_address, stealth_pubkey, amount)` - Deposit funds
- `withdraw(env, token_address, stealth_pubkey, signature, recovery_id, message_hash, recipient, amount)` - Withdraw with signature
- `get_nonce(env, stealth_pubkey)` - Query nonce for replay protection

**Security:**
- Secp256k1 signature verification
- Nonce-based replay attack prevention
- Recipient address in message hash prevents signature reuse

## SDK Usage

### Installation

**From NPM Package (after publishing):**
```bash
npm install @ghost-protocol/sdk
```

**For Local Development:**
```bash
# In SDK directory
npm link

# In your project
npm link @ghost-protocol/sdk
```

### Example: Query Nonce

```typescript
import { VaultClient, Networks } from '@ghost-protocol/sdk';

const vaultClient = new VaultClient({
  contractId: 'CABC1234...',
  rpcUrl: 'https://soroban-testnet.stellar.org',
  networkPassphrase: Networks.TESTNET_NETWORK_PASSPHRASE,
});

const stealthPubkey = Buffer.from('...', 'hex');
const nonce = await vaultClient.getNonce(stealthPubkey);
console.log('Current nonce:', nonce.toString());
```

## Relayer API

The relayer is a backend service that submits transactions on behalf of users, handling gas fees.

### Environment Setup

```bash
# .env
SOROBAN_RPC_URL=https://soroban-testnet.stellar.org
VAULT_CONTRACT_ID=CABC...
RELAYER_SECRET_KEY=S...
PORT=3000
```

### Endpoints

**GET /health**
- Health check

**GET /nonce/:stealthPubkey**
- Query current nonce for a stealth pubkey
- Returns: `{ "nonce": "0" }`

**POST /withdraw**
- Submit stealth withdrawal
- Body: `{ tokenAddress, stealthPubkey, signature, recoveryId, messageHash, recipient, amount }`
- Returns: `{ "txHash": "..." }`

### Running

```bash
npm ci
npm run dev  # Development with hot reload
npm start    # Production
```

## Frontend Setup

### Environment Variables

```bash
# .env.local
REACT_APP_RPC_URL=https://soroban-testnet.stellar.org
REACT_APP_VAULT_CONTRACT_ID=CABC...
REACT_APP_ANNOUNCER_CONTRACT_ID=CABC...
```

### Running

```bash
npm ci
npm start   # Development server on http://localhost:3000
npm build   # Production build
```

### Features

- Freighter wallet integration
- Nonce query interface
- Real-time status messages
- Responsive design

## Deployment

### Contract Deployment

1. **Testnet**
   ```bash
   export SOROBAN_ACCOUNT=GXXXXXX...  # Your account address
   make deploy-testnet
   ```

2. **Mainnet**
   ```bash
   export SOROBAN_ACCOUNT=GXXXXXX...
   make deploy-mainnet
   ```

### SDK Publishing (to GitHub Packages)

```bash
# Configure .npmrc with GitHub token
npm publish
```

### Relayer Deployment

Recommended platforms:
- Railway
- Render
- Heroku
- AWS Lambda (with Node runtime)

```bash
npm run build
npm start
```

### Frontend Deployment

Recommended platforms:
- Vercel
- Netlify
- AWS S3 + CloudFront

```bash
npm run build
# Deploy contents of build/ directory
```

## Production Checklist

### Contracts
- [ ] Run `make lint` and fix clippy warnings
- [ ] Run `make test-contracts` - all tests pass
- [ ] Review security audit: `cargo audit`
- [ ] Deploy to testnet and test end-to-end
- [ ] Final audit review before mainnet

### SDK/Relayer
- [ ] Run `make lint` - no errors
- [ ] Run `make test-sdk` - all tests pass
- [ ] Build succeeds: `npm run build`
- [ ] Published to GitHub Packages
- [ ] Version bumped in package.json

### Frontend
- [ ] Environment variables configured
- [ ] Wallet integration tested
- [ ] Build succeeds: `npm run build`
- [ ] No console errors/warnings
- [ ] Responsive design tested

### Infrastructure
- [ ] Relayer .env configured with mainnet settings
- [ ] Contract IDs updated in all environments
- [ ] RPC endpoints verified
- [ ] Monitoring/logging configured
- [ ] Error tracking (Sentry, etc.) enabled

## Development Commands

```bash
# Makefile commands
make help              # Show all commands
make build             # Build all projects
make test              # Run all tests
make lint              # Run linters
make fmt               # Format code
make clean             # Clean build artifacts
make dev-sdk           # Watch SDK changes
make dev-relayer       # Start relayer in dev mode
make dev-frontend      # Start frontend in dev mode
make deploy-testnet    # Deploy contracts to testnet
make deploy-mainnet    # Deploy contracts to mainnet
make docs              # Generate Rust docs
```

## Testing

### Unit Tests

```bash
# Contracts
cd contracts && cargo test

# SDK
cd sdk && npm test

# Relayer
cd relayer && npm test
```

### Integration Tests

```bash
# Full end-to-end flow (requires live testnet)
# TODO: Add integration test suite
```

## Troubleshooting

### Build Issues

**Rust target missing:**
```bash
rustup target add wasm32-unknown-unknown
```

**soroban-cli not found:**
```bash
cargo install soroban-cli --locked
```

### Runtime Issues

**Contract not found:**
- Verify CONTRACT_ID environment variable
- Check network matches (testnet vs mainnet)
- Verify contract was deployed

**Wallet connection fails:**
- Install Freighter browser extension
- Ensure website origin is whitelisted
- Check browser console for errors

## Security Notes

- Never commit `.env` files with real keys
- Rotate relayer keypairs regularly
- Use testnet for development
- Perform security audit before mainnet deployment
- Monitor contract events and transactions
- Implement rate limiting on relayer endpoints
- Use HTTPS for all production endpoints

## License

MIT

## Support

For issues and questions:
- GitHub Issues: [Link]
- Documentation: [Link]
- Discord: [Link]
