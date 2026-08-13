import React, { useState, useEffect } from 'react';
import { Keypair, Networks } from '@stellar/stellar-sdk';
import freighter from '@stellar/freighter-api';
import { VaultClient, AnnouncerClient } from '@ghost-protocol/sdk';
import './App.css';

interface AppConfig {
  vaultContractId: string;
  announcerContractId: string;
  rpcUrl: string;
}

const config: AppConfig = {
  vaultContractId: process.env.REACT_APP_VAULT_CONTRACT_ID || '',
  announcerContractId: process.env.REACT_APP_ANNOUNCER_CONTRACT_ID || '',
  rpcUrl: process.env.REACT_APP_RPC_URL || 'https://soroban-testnet.stellar.org',
};

function App() {
  const [walletAddress, setWalletAddress] = useState<string | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const connectWallet = async () => {
    try {
      setLoading(true);
      const isAllowed = await freighter.isAllowed();
      if (!isAllowed) {
        setMessage('Freighter wallet not installed');
        return;
      }

      const publicKey = await freighter.getPublicKey();
      setWalletAddress(publicKey);
      setIsConnected(true);
      setMessage('Wallet connected');
    } catch (error) {
      setMessage(`Connection failed: ${error}`);
    } finally {
      setLoading(false);
    }
  };

  const disconnectWallet = () => {
    setWalletAddress(null);
    setIsConnected(false);
    setMessage('Wallet disconnected');
  };

  const getStealthNonce = async () => {
    if (!walletAddress) {
      setMessage('Please connect wallet first');
      return;
    }

    try {
      setLoading(true);
      const vaultClient = new VaultClient({
        contractId: config.vaultContractId,
        rpcUrl: config.rpcUrl,
        networkPassphrase: 'Test SDF Network ; September 2015',
      });

      // Example: fetch nonce for a stealth pubkey
      const exampleStealthPubkey = Buffer.alloc(64);
      const nonce = await vaultClient.getNonce(exampleStealthPubkey);
      setMessage(`Current nonce: ${nonce.toString()}`);
    } catch (error) {
      setMessage(`Error: ${error}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Ghost Protocol Frontend</h1>
        <p>Stealth Transfer Manager</p>
      </header>

      <div className="container">
        <section className="wallet-section">
          <h2>Wallet</h2>
          {!isConnected ? (
            <button onClick={connectWallet} disabled={loading}>
              {loading ? 'Connecting...' : 'Connect Freighter'}
            </button>
          ) : (
            <div>
              <p>Connected: {walletAddress?.slice(0, 10)}...</p>
              <button onClick={disconnectWallet}>Disconnect</button>
            </div>
          )}
        </section>

        <section className="contract-section">
          <h2>Vault Operations</h2>
          <button onClick={getStealthNonce} disabled={!isConnected || loading}>
            {loading ? 'Loading...' : 'Get Nonce'}
          </button>
        </section>

        {message && (
          <section className="message-section">
            <p>{message}</p>
          </section>
        )}

        <section className="info-section">
          <h3>Configuration</h3>
          <ul>
            <li>Vault Contract: {config.vaultContractId || 'Not set'}</li>
            <li>Announcer Contract: {config.announcerContractId || 'Not set'}</li>
            <li>RPC URL: {config.rpcUrl}</li>
          </ul>
        </section>
      </div>
    </div>
  );
}

export default App;
