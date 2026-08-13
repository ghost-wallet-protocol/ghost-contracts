# Deployment Guide

## Prerequisites

- Rust 1.70+ with `wasm32-unknown-unknown` target
- Node.js 18+
- soroban-cli installed
- Stellar account with testnet funds (for testing)

## Testnet Deployment

### 1. Get Your Account

```bash
# Create or use existing account
soroban config identity show default

# Export your public key
export SOROBAN_ACCOUNT=G...
```

### 2. Fund Your Account

Go to https://laboratory.stellar.org/#account-creator?network=testnet and fund your account.

### 3. Build Contracts

```bash
make install-tools
make build
```

### 4. Deploy Contracts

```bash
make deploy-testnet
```

This will output:
```
Announcer Contract ID: CABC...
Vault Contract ID: CABC...
```

### 5. Configure Environment

```bash
# Create .env files
cp .env.example .env
cp relayer/.env.example relayer/.env
cp frontend/.env.example frontend/.env.local

# Edit and add contract IDs
# .env
VAULT_CONTRACT_ID=CABC...
ANNOUNCER_CONTRACT_ID=CABC...

# relayer/.env
VAULT_CONTRACT_ID=CABC...
RELAYER_SECRET_KEY=S...  # Your secret key

# frontend/.env.local
REACT_APP_VAULT_CONTRACT_ID=CABC...
REACT_APP_ANNOUNCER_CONTRACT_ID=CABC...
```

### 6. Start Services

```bash
# Terminal 1: Relayer
cd relayer && npm start

# Terminal 2: Frontend
cd frontend && npm start

# Terminal 3: SDK (for development)
cd sdk && npm run build -- --watch
```

## Mainnet Deployment

**IMPORTANT**: Only deploy to mainnet after:
- ✅ Thorough testnet testing
- ✅ Security audit completed
- ✅ All tests passing
- ✅ Team approval obtained

```bash
# Set mainnet account
export SOROBAN_ACCOUNT=G...

# Deploy to mainnet
make deploy-mainnet
```

## Docker Deployment (Relayer)

### Build Docker Image

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY relayer .
RUN npm install
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

Build and run:
```bash
docker build -t ghost-relayer:latest .
docker run -e VAULT_CONTRACT_ID=CABC... \
           -e RELAYER_SECRET_KEY=S... \
           -e SOROBAN_RPC_URL=https://soroban-mainnet.stellar.org \
           -p 3000:3000 \
           ghost-relayer:latest
```

## Cloud Deployment

### Frontend (Vercel)

```bash
cd frontend
vercel --prod
```

### Frontend (Netlify)

```bash
cd frontend
netlify deploy --prod --dir=build
```

### Relayer (Railway)

1. Connect GitHub repo to Railway
2. Add environment variables
3. Deploy

### Relayer (Render)

1. Create new Web Service
2. Connect GitHub repo
3. Configure:
   - Build: `cd relayer && npm install && npm run build`
   - Start: `npm start`
   - Port: 3000
4. Add environment variables
5. Deploy

## Monitoring & Maintenance

### Check Deployment Status

```bash
# Frontend health
curl https://your-frontend.com/

# Relayer health
curl https://your-relayer.com/health

# Check contract
soroban contract read --id CABC...
```

### View Logs

```bash
# Local
npm run dev 2>&1 | tee app.log

# Vercel
vercel logs

# Railway
railway logs

# Render
# Check in dashboard
```

## Rollback

If deployment fails:

```bash
# View previous deployments
git log --oneline

# Rollback to previous commit
git revert <commit-hash>
git push origin main
```

## Troubleshooting

**Contract deployment fails**
```bash
# Check RPC endpoint is reachable
curl https://soroban-testnet.stellar.org/health

# Check account has funds
soroban account balance --id $SOROBAN_ACCOUNT

# Try again with verbose output
soroban contract deploy ... --verbose
```

**Relayer won't start**
```bash
# Check environment variables
env | grep -E "VAULT|RELAYER|SOROBAN"

# Check port is available
lsof -i :3000

# Check dependencies
npm install
npm run build
npm start
```

**Frontend build fails**
```bash
# Clear cache
rm -rf node_modules package-lock.json
npm install
npm run build
```
