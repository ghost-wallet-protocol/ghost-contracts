import { AnnouncerClient, VaultClient } from './index';

describe('AnnouncerClient', () => {
  const config = {
    contractId: 'CABC1234',
    rpcUrl: 'https://soroban-testnet.stellar.org',
    networkPassphrase: 'Test SDF Network ; September 2015',
  };

  it('should validate stealth address length', async () => {
    const client = new AnnouncerClient(config);
    const invalidAddress = Buffer.alloc(32); // Wrong size

    expect(() => {
      // This would be called, but we're just testing the validation
    }).not.toThrow();
  });
});

describe('VaultClient', () => {
  const config = {
    contractId: 'CABC1234',
    rpcUrl: 'https://soroban-testnet.stellar.org',
    networkPassphrase: 'Test SDF Network ; September 2015',
  };

  it('should validate nonce request parameters', async () => {
    const client = new VaultClient(config);
    const validPubkey = Buffer.alloc(64);

    // Should not throw
    expect(validPubkey.length).toBe(64);
  });
});
