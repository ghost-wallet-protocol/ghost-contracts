# API Reference

## Vault Contract

### `withdraw`

Withdraw funds from a stealth address using ECDSA signature.

**Parameters:**
- `token_address` (Address) - Token contract address
- `stealth_pubkey` (BytesN<64>) - Stealth public key
- `signature` (BytesN<64>) - RS signature (64 bytes)
- `recovery_id` (u32) - Recovery ID for signature
- `message_hash` (BytesN<32>) - Hash of (recipient + nonce)
- `recipient` (Address) - Recipient address
- `amount` (i128) - Amount to withdraw

**Returns:** None (transfers token on success)

**Errors:**
- `Invalid stealth signature` - Signature doesn't match stealth pubkey
- `Nonce replay` - Nonce already used (implicit in contract)

**Example:**
```typescript
const result = await vaultClient.withdraw(keypair, {
  tokenAddress: 'CAAAA...',
  stealthPubkey: Buffer.from('...', 'hex'),
  signature: Buffer.from('...', 'hex'),
  recoveryId: 0,
  messageHash: Buffer.from('...', 'hex'),
  recipient: 'GAAA...',
  amount: BigInt('1000000')
});
```

### `get_nonce`

Get the current nonce for a stealth pubkey.

**Parameters:**
- `stealth_pubkey` (BytesN<64>) - Stealth public key

**Returns:** (u64) - Current nonce for this pubkey

**Example:**
```typescript
const nonce = await vaultClient.getNonce(
  Buffer.from('...', 'hex')
);
console.log('Nonce:', nonce.toString());
```

### `deposit`

Deposit funds under a stealth address.

**Parameters:**
- `token_address` (Address) - Token contract address
- `stealth_pubkey` (BytesN<64>) - Stealth public key
- `amount` (i128) - Amount to deposit

**Returns:** None

**Example:**
```typescript
// Requires contract to be called directly via Soroban
// Not exposed in SDK (use relayer instead)
```

## Announcer Contract

### `announce`

Broadcast a stealth transfer announcement on-chain.

**Parameters:**
- `stealth_address` (BytesN<64>) - Stealth address of recipient
- `ephemeral_pubkey` (BytesN<64>) - Ephemeral public key for this transfer
- `view_tag` (u32) - View tag for optimization
- `metadata` (Bytes) - Optional metadata (amount, token, recipient hint)

**Returns:** None (emits event)

**Event:**
```
Topic: ("announce", stealth_address)
Data: (ephemeral_pubkey, view_tag, metadata)
```

**Example:**
```typescript
await announcerClient.announce(
  keypair,
  stealthAddress,
  ephemeralPubkey,
  42,
  Buffer.from('metadata')
);
```

## Relayer API

### `GET /health`

Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "relayerAddress": "GAAA..."
}
```

### `GET /nonce/:stealthPubkey`

Get current nonce for a stealth pubkey.

**Parameters:**
- `stealthPubkey` (hex string) - 64-byte stealth pubkey (128 hex chars)

**Response:**
```json
{
  "nonce": "0"
}
```

**Example:**
```bash
curl http://localhost:3000/nonce/0000000000000000000000000000000000000000000000000000000000000000
```

### `POST /withdraw`

Submit a withdrawal transaction.

**Body:**
```json
{
  "tokenAddress": "CAAAA...",
  "stealthPubkey": "deadbeef...",
  "signature": "...",
  "recoveryId": 0,
  "messageHash": "...",
  "recipient": "GAAA...",
  "amount": "1000000"
}
```

**Response:**
```json
{
  "txHash": "..."
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/withdraw \
  -H "Content-Type: application/json" \
  -d '{
    "tokenAddress": "CAAAA...",
    "stealthPubkey": "...",
    "signature": "...",
    "recoveryId": 0,
    "messageHash": "...",
    "recipient": "GAAA...",
    "amount": "1000000"
  }'
```

## SDK Classes

### VaultClient

```typescript
class VaultClient {
  constructor(config: VaultContractConfig);
  
  async withdraw(
    keypair: Keypair,
    params: StealthWithdrawalParams
  ): Promise<string>;
  
  async getNonce(stealthPubkey: Buffer): Promise<bigint>;
}
```

### AnnouncerClient

```typescript
class AnnouncerClient {
  constructor(config: AnnouncerContractConfig);
  
  async announce(
    keypair: Keypair,
    stealthAddress: Buffer,
    ephemeralPubkey: Buffer,
    viewTag: number,
    metadata: Buffer
  ): Promise<string>;
}
```

## Interfaces

```typescript
interface VaultContractConfig {
  contractId: string;
  rpcUrl: string;
  networkPassphrase: string;
}

interface StealthWithdrawalParams {
  tokenAddress: string;
  stealthPubkey: Buffer;        // 64 bytes
  signature: Buffer;             // 64 bytes (RS format)
  recoveryId: number;            // 0-3
  messageHash: Buffer;           // 32 bytes
  recipient: string;
  amount: bigint;
}

interface StealthAnnouncementEvent {
  stealthAddress: Buffer;
  ephemeralPubkey: Buffer;
  viewTag: number;
  metadata: Buffer;
}
```
