# Quick Reference

## Common Commands

### Build & Test
```bash
make build              # Build all projects
make test               # Run all tests
make lint               # Check code quality
make fmt                # Format all code
make clean              # Clean artifacts
```

### Development
```bash
make dev-sdk            # Watch SDK changes
make dev-relayer        # Start relayer server (port 3000)
make dev-frontend       # Start frontend (port 3000 - different session)
```

### Deployment
```bash
export SOROBAN_ACCOUNT=GXXXXXX...
make deploy-testnet     # Deploy to testnet
make deploy-mainnet     # Deploy to mainnet
```

### Help
```bash
make help               # Show all commands
```

## Project Structure Quick Guide

```
contracts/              # Soroban smart contracts (Rust)
  ├── announcer/       # Event broadcaster
  └── vault/           # Fund vault
  
sdk/                    # TypeScript SDK (@ghost-protocol/sdk)
relayer/                # Express.js backend server
frontend/               # React UI

scripts/                # Build & deployment automation
.github/workflows/      # GitHub Actions CI/CD
```

## Key Files

| File | Purpose |
|------|---------|
| START_HERE.md | Quick start (5 min) |
| PRODUCTION.md | Complete guide |
| INTEGRATION.md | SDK integration patterns |
| CHECKLIST.md | Deployment checklist |
| Makefile | Development commands |
| .github/workflows/ci.yml | CI/CD pipeline |

## Environment Variables

Copy `.env.example` to `.env` and fill in:

```bash
cp .env.example .env
# Then edit .env with your values
```

## Useful Links

- **Stellar Docs**: https://developers.stellar.org
- **Soroban**: https://developers.stellar.org/learn/soroban
- **Testnet Explorer**: https://stellar.expert/explorer/testnet
- **Freighter Wallet**: https://www.freighter.app

## First Time Setup

```bash
# 1. Install tools
make install-tools

# 2. Build everything
make build

# 3. Run tests
make test

# 4. Start developing
make dev-frontend      # In terminal 1
make dev-relayer       # In terminal 2
make dev-sdk           # In terminal 3 (optional)
```

## Troubleshooting

**Build fails?**
```bash
make clean
make build
```

**Tests fail?**
```bash
make test --verbose
```

**Port already in use?**
```bash
# Change PORT env var
PORT=3001 make dev-frontend
```

**Need help?**
- Check START_HERE.md
- Check PRODUCTION.md
- Check INTEGRATION.md
