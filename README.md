# Ghost Protocol - Stealth Transactions on Stellar

Production-grade Soroban smart contracts for private transactions using stealth addresses on Stellar's Soroban network.

## 🎯 What is Ghost Protocol?

Ghost Protocol enables **private, stealth-based transactions** on Stellar:

- **Announcer Contract**: Broadcasts transfer events for client-side scanning
- **Vault Contract**: Stores and releases funds via ECDSA signature verification

## 🚀 Quick Start

### Prerequisites
- Rust 1.70+
- Make
- soroban-cli

### Build & Test
```bash
# Install tools
make install-tools

# Build contracts
make build

# Run tests
make test
```

### Development
```bash
# Format code
make fmt

# Check linting
make lint
```

## 📦 Project Structure

```
contracts/        # Soroban smart contracts (Rust)
├── announcer/    # Event announcement contract
└── vault/        # Stealth withdrawal contract

scripts/          # Build & deployment scripts
Makefile          # Development commands
```

## 📚 Documentation

- **[PRODUCTION.md](./PRODUCTION.md)** - Complete production guide
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Deployment instructions
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture
- **[START_HERE.md](./START_HERE.md)** - Quick start guide

## 🔧 Common Commands

```bash
make build              # Build contracts
make test               # Run tests
make lint               # Lint code
make fmt                # Format code
make deploy-testnet     # Deploy to testnet
make deploy-mainnet     # Deploy to mainnet
```

## 📖 How It Works

### Stealth Transfer Flow

1. **Sender** generates ephemeral keypair and encrypts to recipient's stealth key
2. **Sender** deposits funds to Vault contract under stealth address
3. **Announcer** broadcasts encrypted announcement event on-chain
4. **Recipient** scans events, decrypts to find funds
5. **Recipient** constructs withdrawal transaction with ECDSA signature
6. **Vault** verifies signature and releases funds to recipient

## 🔒 Security Features

- **ECDSA Signatures**: Secp256k1 signature verification
- **Nonce Replay Protection**: Per-key nonce tracking
- **Recipient Binding**: Message includes recipient address

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

## 📄 License

MIT

## 🤝 Support

- Documentation: [PRODUCTION.md](./PRODUCTION.md)
- Issues: GitHub Issues
- Questions: See documentation
