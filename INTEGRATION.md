# Integration Guide

This document explains how to link the SDK/Contracts repo to your Frontend and Backend repos during development.

## Setup Overview

There are two integration methods:

1. **NPM Package (Production)** - Publish SDK to GitHub Packages or NPM
2. **Local Linking (Development)** - Symlink for instant updates

## Method 1: NPM Package (Production)

### Publishing the SDK

In the `ghost-contracts` repo:

```bash
# Build the SDK
cd sdk && npm install && npm run build && cd ..

# Publish to GitHub Packages (configure .npmrc first)
npm publish
```

### Using in Frontend/Backend

In your frontend or backend repo:

```bash
# Create .npmrc with GitHub token
echo "@ghost-protocol:registry=https://npm.pkg.github.com" >> .npmrc
echo "//npm.pkg.github.com/:_authToken=YOUR_GITHUB_TOKEN" >> .npmrc

# Install SDK
npm install @ghost-protocol/sdk
```

## Method 2: Local Linking (Development)

### Setup Local Link

**Step 1: Link SDK globally**
```bash
cd /workspaces/ghost-contracts/sdk
npm link
```

**Step 2: Link in Frontend**
```bash
cd /path/to/frontend
npm link @ghost-protocol/sdk
```

**Step 3: Link in Relayer (if separate)**
```bash
cd /path/to/relayer
npm link @ghost-protocol/sdk
```

### Using with Watch Mode

For active development, watch SDK changes:

```bash
# In SDK repo
cd sdk && npm run build -- --watch

# Changes automatically reflect in linked repos
```

### Unlinking

When done with local development:

```bash
# In frontend/relayer
npm unlink @ghost-protocol/sdk
npm install

# In SDK repo
npm unlink
```

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                   Ghost Contracts Repo                      │
├─────────────────────────────────────────────────────────────┤
│  /contracts          → Soroban WASM contracts               │
│  /sdk                → TypeScript SDK (published/linked)    │
│  /relayer            → Example backend                      │
│  /frontend           → Example UI                           │
└─────────────────────────────────────────────────────────────┘
         │
         │ npm link / npm publish
         │
    ┌────┴────┬───────────────┐
    │          │               │
    ▼          ▼               ▼
┌────────┐  ┌────────┐   ┌──────────┐
│ Your   │  │ Your   │   │ Stellar  │
│Frontend│  │Relayer │   │  RPC     │
└────────┘  └────────┘   └──────────┘
```

## Contract Integration

When deploying contracts, the contract IDs must be shared with SDK/Frontend/Relayer:

```
Deployment:
  make deploy-testnet
  → Outputs: ANNOUNCER_CONTRACT_ID, VAULT_CONTRACT_ID

Environment variables:
  Frontend:  REACT_APP_VAULT_CONTRACT_ID=CABC...
  Relayer:   VAULT_CONTRACT_ID=CABC...
  SDK:       (contracts are passed via config objects)
```

## Example: Full Integration Flow

### 1. Deploy Contracts

```bash
cd ghost-contracts
export SOROBAN_ACCOUNT=GXXXXXX...
make deploy-testnet

# Copy contract IDs from output
```

### 2. Link SDK Locally

```bash
cd ghost-contracts/sdk
npm link
```

### 3. Use SDK in Frontend

```bash
cd your-frontend-repo
npm link @ghost-protocol/sdk
echo "REACT_APP_VAULT_CONTRACT_ID=CABC..." > .env.local
npm start
```

### 4. Use SDK in Relayer

```bash
cd your-relayer-repo
npm link @ghost-protocol/sdk
echo "VAULT_CONTRACT_ID=CABC..." > .env
npm run dev
```

## Troubleshooting

### "Cannot find module" error

```bash
# Verify link was created
npm ls -g @ghost-protocol/sdk

# Re-link if needed
npm unlink @ghost-protocol/sdk
npm link @ghost-protocol/sdk
```

### Changes not reflecting

```bash
# Rebuild SDK
cd sdk && npm run build && cd ..

# Restart dev server (some dev servers cache modules)
npm start
```

### Version mismatches

Always ensure versions match between repos:

```bash
# Check SDK version
cat sdk/package.json | grep version

# Update in dependent repos to same version
```

## For CI/CD

In GitHub Actions or other CI systems, use published packages:

```yaml
- run: npm install @ghost-protocol/sdk@latest
```

Never use local linking in CI/CD - only for local development.
