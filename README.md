# Ghost Protocol - Stealth Transactions on Stellar

Production-grade Soroban smart contracts and SDK for private transactions using stealth addresses on Stellar's Soroban network.

## 🎯 What is Ghost Protocol?

Ghost Protocol enables **private, stealth-based transactions** on Stellar:

- **Announcer Contract**: Broadcasts transfer events for client-side scanning
- **Vault Contract**: Stores and releases funds via ECDSA signature verification
- **TypeScript SDK**: Type-safe client library for contract interaction
- **Relayer Backend**: Handles fee-bumped transactions on behalf of users
- **React Frontend**: User-friendly interface for stealth transfers

## 🚀 Quick Start

### Prerequisites
- Rust 1.70+
- Node.js 18+
- Make

### Build & Test
```bash
# Install tools
make install-tools

# Build everything
make build

# Run tests
make test
```

### Development
```bash
# Terminal 1: SDK development
make dev-sdk

# Terminal 2: Relayer
make dev-relayer

# Terminal 3: Frontend
make dev-frontend
```

## 📦 Project Structure

```
contracts/        # Soroban smart contracts (Rust)
├── announcer/    # Event announcement contract
└── vault/        # Stealth withdrawal contract

sdk/              # TypeScript SDK & ABIs
relayer/          # Backend relayer server (Express)
frontend/         # React frontend
scripts/          # Build & deployment scripts
```

## 📚 Documentation

- **[PRODUCTION.md](./PRODUCTION.md)** - Complete production guide, architecture, and API documentation
- **[Makefile](./Makefile)** - All development commands
- **[.github/workflows/ci.yml](.github/workflows/ci.yml)** - CI/CD pipeline

## 🔧 Common Commands

```bash
make build              # Build contracts, SDK, relayer, frontend
make test               # Run all tests
make lint               # Run linters
make fmt                # Format all code
make deploy-testnet     # Deploy to testnet
make deploy-mainnet     # Deploy to mainnet
make dev-*              # Development mode (sdk, relayer, frontend)
```

## 🏗️ Architecture

```
Frontend (React)
     ↓
SDK (@ghost-protocol)
     ↓ fetch
Relayer (Express) ← → Soroban Contracts
     ↓                    ↓
   Stellar RPC      Stellar Network
```

## 📖 How It Works

### Stealth Transfer Flow

1. **Sender** generates ephemeral keypair and encrypts to recipient's stealth key
2. **Sender** deposits funds to Vault contract under stealth address
3. **Announcer** broadcasts encrypted announcement event on-chain
4. **Recipient** scans events, decrypts to find funds
5. **Recipient** constructs withdrawal transaction with ECDSA signature
6. **Relayer** submits transaction and pays gas fees
7. **Vault** verifies signature and releases funds to recipient

## 🔒 Security Features

- **ECDSA Signatures**: Secp256k1 signature verification
- **Nonce Replay Protection**: Per-key nonce tracking
- **Recipient Binding**: Message includes recipient address
- **No Private Keys on Backend**: Signatures created offline by client

## 📦 SDK Usage

```bash
npm install @ghost-protocol/sdk
```

```typescript
import { VaultClient, Networks, Keypair } from '@ghost-protocol/sdk';

const vaultClient = new VaultClient({
  contractId: 'CAB...',
  rpcUrl: 'https://soroban-testnet.stellar.org',
  networkPassphrase: Networks.TESTNET_NETWORK_PASSPHRASE,
});

// Get nonce for transaction construction
const nonce = await vaultClient.getNonce(stealthPubkey);
```

## 🌐 Relayer API

```bash
# Start relayer
cd relayer && npm start
```

**Endpoints:**
- `GET /health` - Health check
- `GET /nonce/:stealthPubkey` - Get current nonce
- `POST /withdraw` - Submit withdrawal transaction

See [relayer/README.md](./relayer/README.md) for full API docs.

## 🎨 Frontend

```bash
cd frontend && npm start
```

Opens at http://localhost:3000

Features:
- Freighter wallet integration
- Nonce queries
- Transaction status monitoring

## 🚀 Deployment

### Testnet
```bash
export SOROBAN_ACCOUNT=G...
make deploy-testnet
```

### Mainnet
```bash
export SOROBAN_ACCOUNT=G...
make deploy-mainnet
```

## ✅ Production Checklist

- [ ] All tests passing (`make test`)
- [ ] No lint warnings (`make lint`)
- [ ] Security audit complete (`cargo audit`)
- [ ] Testnet deployment verified
- [ ] Environment variables configured
- [ ] Relayer monitoring enabled
- [ ] Frontend build tested

See [PRODUCTION.md](./PRODUCTION.md) for complete checklist.

## 📄 License

MIT

## 🤝 Support

- Documentation: [PRODUCTION.md](./PRODUCTION.md)
- Issues: GitHub Issues
- Questions: See documentation
