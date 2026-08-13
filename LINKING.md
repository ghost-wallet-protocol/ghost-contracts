# Linking Ghost Protocol Contracts with Other Projects

This guide explains how to link the contracts repository with your SDK, frontend, and relayer projects.

## Method 1: Local Development Linking (Fastest)

Use npm link during development so changes in contracts automatically reflect in dependent projects.

### Step 1: Link Contracts Globally

In this repository:
```bash
npm link
```

This creates a global symlink to `@ghost-protocol/contracts`.

### Step 2: Link in Your Projects

In your SDK, frontend, or relayer repository:
```bash
npm link @ghost-protocol/contracts
```

### Step 3: Access Contract Artifacts

In your project code, you can reference the built WASM contracts:

```javascript
// Frontend/SDK/Relayer
const contractsPath = require.resolve('@ghost-protocol/contracts');
const wasmPath = `${contractsPath}/../../contracts/vault/target/wasm32-unknown-unknown/release/ghost_vault.wasm`;
```

Or in package.json scripts:
```json
{
  "scripts": {
    "build": "node scripts/copy-contracts.js && webpack build"
  }
}
```

### Step 4: Copy Contracts Script

Create `scripts/copy-contracts.js` in your project:
```javascript
const fs = require('fs');
const path = require('path');

// Find where @ghost-protocol/contracts is linked
const contractsPath = require.resolve('@ghost-protocol/contracts/package.json');
const contractsDir = path.dirname(contractsPath);

// Copy built WASM to your project
const srcVault = path.join(contractsDir, 'contracts/vault/target/wasm32-unknown-unknown/release/ghost_vault.wasm');
const srcAnnouncer = path.join(contractsDir, 'contracts/announcer/target/wasm32-unknown-unknown/release/ghost_announcer.wasm');

const dstDir = path.join(process.cwd(), 'contracts/wasm');
fs.mkdirSync(dstDir, { recursive: true });

if (fs.existsSync(srcVault)) {
  fs.copyFileSync(srcVault, path.join(dstDir, 'ghost_vault.wasm'));
  console.log('✓ Copied vault contract');
}

if (fs.existsSync(srcAnnouncer)) {
  fs.copyFileSync(srcAnnouncer, path.join(dstDir, 'ghost_announcer.wasm'));
  console.log('✓ Copied announcer contract');
}
```

### Step 5: Unlink When Done

When you're done developing:
```bash
# In your project
npm unlink @ghost-protocol/contracts

# In contracts repo (optional cleanup)
npm unlink
```

## Method 2: NPM Package (Production)

For production use, publish the contracts package to npm or GitHub Packages.

### Step 1: Publish

In this repository:
```bash
npm publish
# or for GitHub Packages:
npm publish --registry https://npm.pkg.github.com
```

### Step 2: Install in Projects

In your SDK, frontend, or relayer repository:
```bash
npm install @ghost-protocol/contracts
```

### Step 3: Use in Your Code

```javascript
import contractsPackage from '@ghost-protocol/contracts/package.json';

// Access built WASM files
const wasmDir = `node_modules/@ghost-protocol/contracts/contracts`;
```

## Method 3: Git Submodule (Tight Integration)

For very tight integration, use git submodules.

### Step 1: Add Submodule

In your project repository:
```bash
git submodule add https://github.com/ghost-wallet-protocol/ghost-contracts contracts/ghost
```

### Step 2: Update Submodule

```bash
git submodule update --remote --merge
```

### Step 3: Build Contracts

```bash
cd contracts/ghost
make build
cd ../..
```

## Which Method to Use?

| Method | Best For | Setup | Changes Reflect |
|--------|----------|-------|-----------------|
| Local Link | Active Development | Easy (2 commands) | Immediate |
| NPM Package | Production | Medium (publish) | After publish |
| Git Submodule | Monorepo | Complex | Manual updates |

**Recommendation**: Use **Method 1 (Local Linking)** during development, then **Method 2 (NPM Package)** for releases.

## Example Workflow

### Development
```bash
# 1. In ghost-contracts repo
npm link

# 2. In ghost-sdk repo
npm link @ghost-protocol/contracts

# 3. Make changes to contracts
cd ../ghost-contracts
make build  # Rebuilds WASM

# 4. SDK automatically sees updated WASM
# No need to re-link or reinstall!
```

### Release
```bash
# 1. Tag and publish contracts
git tag v0.2.0
npm publish

# 2. Update SDK to use new version
npm install @ghost-protocol/contracts@0.2.0
```

## Troubleshooting

### "Cannot find module '@ghost-protocol/contracts'"
```bash
# Make sure you've run npm link in contracts repo
cd ghost-contracts
npm link

# Then re-link in your project
cd ../your-project
npm link @ghost-protocol/contracts
```

### "WASM file not found"
```bash
# Rebuild contracts
cd ghost-contracts
make build

# Verify WASM exists
ls contracts/vault/target/wasm32-unknown-unknown/release/
```

### Changes not reflecting
```bash
# If using local link, restart your dev server
# If using npm package, reinstall
npm install @ghost-protocol/contracts@latest
```

## CI/CD Integration

In your GitHub Actions workflows:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true  # If using git submodule method
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install contracts
        run: npm install @ghost-protocol/contracts
      
      - name: Build
        run: npm run build
```

## Summary

The contracts repository is designed to be consumed by:
- **ghost-sdk** - TypeScript SDK that uses contract ABIs
- **ghost-frontend** - React app that integrates SDK
- **ghost-relayer** - Backend that deploys and calls contracts

Use local linking during development and npm packages for releases.
