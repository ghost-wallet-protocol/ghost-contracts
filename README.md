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

# Build SDK
make build

# Run tests
make test
```

### Development
```bash
# SDK development mode
make dev-sdk
```

## 📦 Project Structure

```
contracts/        # Soroban smart contracts (Rust)
├── announcer/    # Event announcement contract
└── vault/        # Stealth withdrawal contract

sdk/              # TypeScript SDK (@ghost-protocol/sdk)
  ├── src/
  │   ├── index.ts         # Client library
  │   └── index.test.ts    # Unit tests
  └── dist/                # Compiled output

scripts/          # Build & deployment scripts
Makefile          # Development commands
```

## 📚 Documentation

- **[PRODUCTION.md](./PRODUCTION.md)** - Complete production guide, architecture, and API documentation
- **[Makefile](./Makefile)** - All development commands
- **[.github/workflows/ci.yml](.github/workflows/ci.yml)** - CI/CD pipeline

## 🔧 Common Commands

```bash
make build              # Build SDK
make test               # Run SDK tests
make lint               # Run linters
make fmt                # Format code
make dev-sdk            # Development mode
make deploy-testnet     # Deploy contracts to testnet
make deploy-mainnet     # Deploy contracts to mainnet
```

## 🏗️ Architecture

```
Frontend (React)
     ↓ (imports SDK)
SDK (@ghost-protocol/sdk)
     ↓ (calls contracts via RPC)
Soroban Contracts
     ↓
Stellar Network
```

## 📚 Related Repositories

- **[ghost-frontend](https://github.com/ghost-wallet-protocol/ghost-frontend)** - React UI
- **[ghost-relayer](https://github.com/ghost-wallet-protocol/ghost-relayer)** - Backend server

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

## 🌐 Usage

Install the SDK in your frontend or backend:

```bash
npm install @ghost-protocol/sdk
```

Use in your application:

```typescript
import { VaultClient, AnnouncerClient, Keypair, Networks } from '@ghost-protocol/sdk';

const vaultClient = new VaultClient({
  contractId: 'CAB...',
  rpcUrl: 'https://soroban-testnet.stellar.org',
  networkPassphrase: Networks.TESTNET_NETWORK_PASSPHRASE,
});

// Get nonce for transaction construction
const nonce = await vaultClient.getNonce(stealthPubkey);
```

See [SDK documentation](./sdk/README.md) for more examples.

## 🌐 Relayer API

The relayer backend is a separate project. See [ghost-relayer](https://github.com/ghost-wallet-protocol/ghost-relayer) for API documentation:

- `GET /health` - Health check
- `GET /nonce/:stealthPubkey` - Get current nonce
- `POST /withdraw` - Submit withdrawal transaction

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
