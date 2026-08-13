# Relayer Configuration

## Environment Variables

```env
# Soroban RPC endpoint
SOROBAN_RPC_URL=https://soroban-testnet.stellar.org

# Deployed Vault contract ID
VAULT_CONTRACT_ID=CABC...1234

# Relayer keypair (secret key that pays for gas)
RELAYER_SECRET_KEY=S...

# Server port
PORT=3000
```

## Running Locally

```bash
npm install
npm run dev
```

## API Endpoints

### GET /health
Health check endpoint

### GET /nonce/:stealthPubkey
Get the current nonce for a stealth pubkey (used for offline transaction construction)

**Parameters:**
- `stealthPubkey` (hex string, 128 chars) - 64-byte stealth public key

**Response:**
```json
{
  "nonce": "0"
}
```

### POST /withdraw
Submit a pre-signed stealth withdrawal transaction

**Body:**
```json
{
  "tokenAddress": "CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABSC4",
  "stealthPubkey": "deadbeef...",
  "signature": "...",
  "recoveryId": 0,
  "messageHash": "...",
  "recipient": "GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWHF46Q",
  "amount": "1000000"
}
```

**Response:**
```json
{
  "txHash": "..."
}
```
