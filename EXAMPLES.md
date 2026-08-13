# Examples

## Basic SDK Usage

### Query Nonce

```typescript
import { VaultClient } from '@ghost-protocol/sdk';

const vaultClient = new VaultClient({
  contractId: 'CABC123...',
  rpcUrl: 'https://soroban-testnet.stellar.org',
  networkPassphrase: 'Test SDF Network ; September 2015',
});

// Generate or get stealth pubkey (64 bytes)
const stealthPubkey = Buffer.alloc(64);

// Query nonce
const nonce = await vaultClient.getNonce(stealthPubkey);
console.log('Current nonce:', nonce.toString());
```

## Frontend Integration

### Connect Wallet & Query Nonce

```typescript
import React, { useState } from 'react';
import freighter from '@stellar/freighter-api';
import { VaultClient } from '@ghost-protocol/sdk';

function StealthTransfer() {
  const [nonce, setNonce] = useState<string>('');
  const [loading, setLoading] = useState(false);

  const handleConnectWallet = async () => {
    try {
      const isAllowed = await freighter.isAllowed();
      if (!isAllowed) {
        alert('Freighter wallet not installed');
        return;
      }

      const publicKey = await freighter.getPublicKey();
      console.log('Connected:', publicKey);
    } catch (error) {
      console.error('Connection failed:', error);
    }
  };

  const handleGetNonce = async () => {
    try {
      setLoading(true);

      const vaultClient = new VaultClient({
        contractId: process.env.REACT_APP_VAULT_CONTRACT_ID || '',
        rpcUrl: 'https://soroban-testnet.stellar.org',
        networkPassphrase: 'Test SDF Network ; September 2015',
      });

      // Example: all zeros for demo
      const stealthPubkey = Buffer.alloc(64);
      const currentNonce = await vaultClient.getNonce(stealthPubkey);
      setNonce(currentNonce.toString());
    } catch (error) {
      console.error('Error:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <button onClick={handleConnectWallet}>Connect Freighter</button>
      <button onClick={handleGetNonce} disabled={loading}>
        {loading ? 'Loading...' : 'Get Nonce'}
      </button>
      {nonce && <p>Nonce: {nonce}</p>}
    </div>
  );
}

export default StealthTransfer;
```

## Relayer Integration

### Submit Withdrawal

```typescript
const submitWithdrawal = async (withdrawalData: {
  tokenAddress: string;
  stealthPubkey: string;
  signature: string;
  recoveryId: number;
  messageHash: string;
  recipient: string;
  amount: string;
}) => {
  const response = await fetch('http://localhost:3000/withdraw', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(withdrawalData),
  });

  const result = await response.json();
  console.log('Transaction hash:', result.txHash);
  return result.txHash;
};

// Usage
const txHash = await submitWithdrawal({
  tokenAddress: 'CAAAA...',
  stealthPubkey: '0000...0000',
  signature: 'deadbeef...',
  recoveryId: 0,
  messageHash: '1234...',
  recipient: 'GAAA...',
  amount: '1000000',
});
```

## Complete Stealth Transfer Flow

```typescript
import { Keypair, Networks } from '@stellar/stellar-sdk';
import { VaultClient } from '@ghost-protocol/sdk';
import crypto from 'crypto';

async function performStealthTransfer() {
  // 1. Generate stealth keypair (offline)
  const stealthKeypair = Keypair.random();
  const stealthPubkey = Buffer.from(stealthKeypair.publicKey(), 'utf8');

  // 2. Generate ephemeral keypair
  const ephemeralKeypair = Keypair.random();
  const ephemeralPubkey = Buffer.from(ephemeralKeypair.publicKey(), 'utf8');

  // 3. Query nonce from relayer
  const relayerResponse = await fetch(`/nonce/${stealthPubkey.toString('hex')}`);
  const { nonce } = await relayerResponse.json();

  // 4. Create message to sign
  const message = Buffer.concat([
    Buffer.from('recipient_address'),
    Buffer.from(nonce.toString()),
  ]);

  // 5. Hash message
  const messageHash = crypto.createHash('sha256').update(message).digest();

  // 6. Sign with stealth key (ECDSA Secp256k1 in real implementation)
  // This is pseudocode - real signing uses secp256k1
  const signature = Buffer.from('signature_bytes');
  const recoveryId = 0;

  // 7. Submit to relayer
  const withdrawalResponse = await fetch('/withdraw', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      tokenAddress: 'CAAAA...',
      stealthPubkey: stealthPubkey.toString('hex'),
      signature: signature.toString('hex'),
      recoveryId,
      messageHash: messageHash.toString('hex'),
      recipient: 'GAAA...', // Recipient address
      amount: '1000000',
    }),
  });

  const { txHash } = await withdrawalResponse.json();
  console.log('Transaction submitted:', txHash);

  return txHash;
}

// Run the transfer
performStealthTransfer().catch(console.error);
```

## Error Handling

```typescript
async function safeWithdraw(params: StealthWithdrawalParams) {
  try {
    const vaultClient = new VaultClient(config);
    const result = await vaultClient.withdraw(keypair, params);
    return result;
  } catch (error) {
    if (error instanceof Error) {
      if (error.message.includes('Invalid stealth signature')) {
        console.error('Signature verification failed - check your signing key');
      } else if (error.message.includes('Nonce')) {
        console.error('Nonce mismatch - try refreshing nonce');
      } else if (error.message.includes('Contract invocation')) {
        console.error('Contract ABI not available - ensure SDK is built');
      } else {
        console.error('Unexpected error:', error.message);
      }
    }
    throw error;
  }
}
```

## Testing Locally

### 1. Start All Services

```bash
# Terminal 1
make dev-sdk

# Terminal 2
make dev-relayer

# Terminal 3
make dev-frontend
```

### 2. Test Endpoints

```bash
# Health check
curl http://localhost:3000/health

# Get nonce (all zeros pubkey)
curl "http://localhost:3000/nonce/0000000000000000000000000000000000000000000000000000000000000000"

# Submit withdrawal
curl -X POST http://localhost:3000/withdraw \
  -H "Content-Type: application/json" \
  -d '{
    "tokenAddress": "CAAAA...",
    "stealthPubkey": "0000...0000",
    "signature": "0000...0000",
    "recoveryId": 0,
    "messageHash": "0000...0000",
    "recipient": "GAAA...",
    "amount": "1000000"
  }'
```

### 3. Test Frontend

1. Open http://localhost:3000
2. Click "Connect Freighter" (need wallet installed)
3. Click "Get Nonce"
4. Should display: "Current nonce: 0"

## Common Patterns

### Initialize SDK Client

```typescript
import { VaultClient, AnnouncerClient } from '@ghost-protocol/sdk';

const vaultClient = new VaultClient({
  contractId: process.env.REACT_APP_VAULT_CONTRACT_ID || '',
  rpcUrl: process.env.REACT_APP_RPC_URL || 'https://soroban-testnet.stellar.org',
  networkPassphrase: 'Test SDF Network ; September 2015',
});

const announcerClient = new AnnouncerClient({
  contractId: process.env.REACT_APP_ANNOUNCER_CONTRACT_ID || '',
  rpcUrl: process.env.REACT_APP_RPC_URL || 'https://soroban-testnet.stellar.org',
  networkPassphrase: 'Test SDF Network ; September 2015',
});
```

### Buffer Handling

```typescript
// Convert hex string to Buffer
const pubkeyBuffer = Buffer.from('deadbeef...', 'hex');

// Convert Buffer to hex string
const pubkeyHex = pubkeyBuffer.toString('hex');

// Generate random buffer
const randomBuffer = Buffer.alloc(64); // Or use crypto.randomBytes(64)
```
