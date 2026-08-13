import express, { Request, Response } from 'express';
import pinoHttp from 'pino-http';
import { VaultClient } from '@ghost-protocol/sdk';
import { Keypair, Networks, StrKey } from '@stellar/stellar-sdk';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const logger = pinoHttp();

app.use(logger);
app.use(express.json());

// Configuration
const SOROBAN_RPC_URL = process.env.SOROBAN_RPC_URL || 'https://soroban-testnet.stellar.org';
const VAULT_CONTRACT_ID = process.env.VAULT_CONTRACT_ID || '';
const RELAYER_SECRET_KEY = process.env.RELAYER_SECRET_KEY || '';
const NETWORK_PASSPHRASE = 'Test SDF Network ; September 2015';

// Initialize clients
const relayerKeypair = Keypair.fromSecret(RELAYER_SECRET_KEY);
const vaultClient = new VaultClient({
  contractId: VAULT_CONTRACT_ID,
  rpcUrl: SOROBAN_RPC_URL,
  networkPassphrase: NETWORK_PASSPHRASE,
});

/**
 * Health check endpoint
 */
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', relayerAddress: relayerKeypair.publicKey() });
});

/**
 * Get nonce for a stealth pubkey
 * Used by clients to construct offline transactions
 */
app.get('/nonce/:stealthPubkey', async (req: Request, res: Response) => {
  try {
    const { stealthPubkey } = req.params;

    // Validate hex encoding and length
    const pubkeyBuffer = Buffer.from(stealthPubkey, 'hex');
    if (pubkeyBuffer.length !== 64) {
      return res.status(400).json({ error: 'stealthPubkey must be 64 bytes (128 hex chars)' });
    }

    const nonce = await vaultClient.getNonce(pubkeyBuffer);
    res.json({ nonce: nonce.toString() });
  } catch (error) {
    req.log.error(error);
    res.status(500).json({ error: 'Failed to fetch nonce' });
  }
});

/**
 * Submit a withdrawal transaction
 * Client sends a pre-signed stealth withdrawal, relayer pays gas and submits
 */
app.post('/withdraw', async (req: Request, res: Response) => {
  try {
    const { tokenAddress, stealthPubkey, signature, recoveryId, messageHash, recipient, amount } = req.body;

    // Validate inputs
    if (!tokenAddress || !stealthPubkey || !signature || !messageHash || !recipient || !amount) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Convert hex strings to buffers
    const pubkeyBuffer = Buffer.from(stealthPubkey, 'hex');
    const sigBuffer = Buffer.from(signature, 'hex');
    const hashBuffer = Buffer.from(messageHash, 'hex');

    // Submit withdrawal via vault client
    const txHash = await vaultClient.withdraw(relayerKeypair, {
      tokenAddress,
      stealthPubkey: pubkeyBuffer,
      signature: sigBuffer,
      recoveryId: parseInt(recoveryId),
      messageHash: hashBuffer,
      recipient,
      amount: BigInt(amount),
    });

    res.json({ txHash });
  } catch (error) {
    req.log.error(error);
    res.status(500).json({ error: 'Withdrawal submission failed' });
  }
});

/**
 * Health metrics endpoint
 */
app.get('/metrics', (req: Request, res: Response) => {
  res.json({
    uptime: process.uptime(),
    relayerAddress: relayerKeypair.publicKey(),
    sorobanRpc: SOROBAN_RPC_URL,
    vaultContractId: VAULT_CONTRACT_ID,
  });
});

// Error handling middleware
app.use((err: any, req: Request, res: Response, next: any) => {
  req.log.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Relayer listening on port ${PORT}`);
});
