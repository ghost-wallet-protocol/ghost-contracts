# Architecture Overview

## System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                       User's Browser                            │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │            React Frontend (port 3000)                    │  │
│  │  • Freighter wallet integration                          │  │
│  │  • Stealth address generation                           │  │
│  │  • Transaction signing                                  │  │
│  └──────────────────────────┬────────────────────────────────┘  │
└─────────────────────────────┼──────────────────────────────────┘
                              │ fetch() API calls
                    ┌─────────▼─────────┐
                    │  Relayer Backend  │ (Express, port 3000)
                    │ ┌───────────────┐ │
                    │ │ /health       │ │
                    │ │ /nonce/:key   │ │
                    │ │ /withdraw     │ │
                    │ └───────────────┘ │
                    └──────────┬────────┘
                               │ soroban-sdk calls
                    ┌──────────▼─────────────┐
                    │  SDK Clients           │
                    │ ┌────────────────────┐ │
                    │ │ VaultClient        │ │
                    │ │ AnnouncerClient    │ │
                    │ └────────────────────┘ │
                    └──────────┬─────────────┘
                               │ Contract invocations
          ┌────────────────────┴────────────────────┐
          │                                         │
    ┌─────▼──────────┐                    ┌────────▼──────┐
    │ Announcer      │                    │ Vault         │
    │ Contract       │                    │ Contract      │
    ├───────────────┤                    ├──────────────┤
    │ • announce()  │                    │ • withdraw() │
    │ • Events      │                    │ • getNonce() │
    │ • Metadata    │                    │ • Nonce store│
    └────────┬──────┘                    └────────┬──────┘
             │                                    │
             └────────────┬─────────────────────┘
                          │
                ┌─────────▼────────┐
                │ Stellar Network  │
                │                  │
                │ • Mainnet        │
                │ • Testnet        │
                └──────────────────┘
```

## Data Flow: Stealth Transfer

### 1. Sender Side

1. Generate ephemeral keypair
2. Encrypt to recipient's stealth key
3. Deposit funds to Vault under stealth address
4. Call Announcer to broadcast announcement

### 2. Recipient Scanning

1. Listen for Announcer events on-chain
2. Decrypt announcements using stealth key
3. Identify funds meant for them
4. Construct withdrawal transaction offline

### 3. Withdrawal Submission

1. Sign withdrawal message (recipient + nonce) with stealth key
2. Submit to Relayer
3. Relayer submits fee-bumped transaction to blockchain
4. Vault verifies signature and releases funds

## Contract State Management

### Announcer Contract

**Storage:**
- Immutable - Only emits events
- No persistent state

**Events:**
```
Event: ("announce", stealth_address)
Data: (ephemeral_pubkey, view_tag, metadata)
```

### Vault Contract

**Storage:**
```
nonce_key = ("nonce", stealth_pubkey)
nonce_value = u64 (current nonce for this pubkey)
```

**Security:**
- Incremented after each withdrawal
- Prevents replay attacks
- Recoverable from blockchain state

## Security Model

### ECDSA Signature Verification

1. **Message Format**: `recipient_address || nonce`
2. **Signature Algorithm**: Secp256k1
3. **Verification**: `recovered_pubkey == stealth_pubkey`
4. **Recovery**: Uses signature + recovery_id to recover pubkey

### Nonce Protection

1. Query nonce before signing: `GET /nonce/:stealthPubkey`
2. Include in message: `message_hash = keccak256(recipient || nonce)`
3. Sign message offline
4. Submit with signature
5. Contract increments nonce

### No Keys on Backend

- Relayer never sees private keys
- Signatures created client-side
- Relayer only submits pre-signed transactions

## Integration Points

### Frontend → SDK

```typescript
import { VaultClient } from '@ghost-protocol/sdk';

const client = new VaultClient(config);
const nonce = await client.getNonce(pubkey);
```

### Frontend → Relayer

```typescript
fetch('/withdraw', {
  method: 'POST',
  body: JSON.stringify({
    tokenAddress, signature, nonce, ...
  })
});
```

### Relayer → Contracts

```typescript
// Via SDK
const vaultClient = new VaultClient(config);
await vaultClient.withdraw(keypair, params);
```

### SDK → Soroban RPC

```typescript
// Via @stellar/stellar-sdk
const server = new SorobanRpc.Server(rpcUrl);
const tx = await server.sendTransaction(envelope);
```

## Deployment Topology

### Local Development
```
Frontend (localhost:3000)
Relayer (localhost:3000, separate terminal)
SDK (hot reload)
```

### Testnet
```
Frontend → Vercel/Netlify
Relayer → Railway/Render
SDK → npm package registry
Contracts → Stellar Testnet
```

### Mainnet
```
Frontend → Vercel/Netlify  (production)
Relayer → AWS Lambda       (serverless)
SDK → npm registry         (@ghost-protocol/sdk)
Contracts → Stellar Mainnet
```

## Technology Stack

| Component | Tech | Why |
|-----------|------|-----|
| Contracts | Rust + Soroban | Type-safe, efficient WASM |
| SDK | TypeScript | Type-safe client library |
| Relayer | Express.js + Node.js | Lightweight, fast API |
| Frontend | React | Rich UI, component reuse |
| Crypto | ECDSA Secp256k1 | Industry standard |
| Network | Stellar | Decentralized, scalable |

## Performance Characteristics

| Operation | Time | Notes |
|-----------|------|-------|
| Query nonce | 100ms | RPC call |
| Sign transaction | 10ms | Client-side |
| Submit withdrawal | 500ms-2s | Network dependent |
| Confirm on blockchain | 5-10s | Stellar consensus |

## Scalability

- **Contracts**: No state explosion (just nonces)
- **Relayer**: Stateless, horizontally scalable
- **Frontend**: Static, CDN-friendly
- **SDK**: Lightweight (~5KB gzipped)

## Future Enhancements

1. **Multi-hop transfers** - Privacy pool
2. **Threshold signatures** - Multi-sig stealth addresses
3. **Batch withdrawals** - Reduce transaction count
4. **Privacy pools** - Mixing for larger anonymity set
5. **Automated market maker** - For value transfer
