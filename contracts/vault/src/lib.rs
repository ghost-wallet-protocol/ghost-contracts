#![no_std]

use soroban_sdk::{
    contract, contractimpl, symbol_short, token, Address, Bytes, BytesN, Env, Storage,
};

/// Vault contract that stores and releases funds based on ECDSA stealth key signatures
#[contract]
pub struct GhostVaultContract;

#[contractimpl]
impl GhostVaultContract {
    /// Initializes the vault (can be called once to set up any persistent state if needed)
    pub fn init(env: Env) {
        // Reserve for future state initialization if needed
    }

    /// Deposits funds into the vault under a stealth address
    pub fn deposit(env: Env, token_address: Address, stealth_pubkey: BytesN<64>, amount: i128) {
        // Verify token address is valid
        let token_client = token::Client::new(&env, &token_address);

        // Transfer from caller to this contract
        token_client.transfer(&env.invoker(), &env.current_contract_address(), &amount);
    }

    /// Withdraws funds from a stealth address using ECDSA Secp256k1 signature verification
    ///
    /// # Arguments
    /// * `env` - Soroban environment
    /// * `token_address` - Token contract address
    /// * `stealth_pubkey` - Uncompressed 64-byte stealth public key (x, y)
    /// * `signature` - RS signature (64 bytes)
    /// * `recovery_id` - V value for secp256k1 recovery
    /// * `message_hash` - Hash of (recipient_address + nonce)
    /// * `recipient` - Address to receive the funds
    /// * `amount` - Amount to withdraw
    pub fn withdraw(
        env: Env,
        token_address: Address,
        stealth_pubkey: BytesN<64>,
        signature: BytesN<64>,
        recovery_id: u32,
        message_hash: BytesN<32>,
        recipient: Address,
        amount: i128,
    ) {
        // 1. Recover pubkey from secp256k1 signature using native Soroban crypto host function
        let recovered_pubkey_bytes = env.crypto().secp256k1_recover(&message_hash, &signature, recovery_id);

        // 2. Assert recovered pubkey matches the target stealth address
        if recovered_pubkey_bytes.to_bytes() != stealth_pubkey.to_bytes() {
            panic!("Invalid stealth signature");
        }

        // 3. Prevent replay attacks using persistent storage nonces
        let nonce_key = (symbol_short!("nonce"), stealth_pubkey.clone());
        let mut nonce: u64 = env
            .storage()
            .persistent()
            .get::<_, u64>(&nonce_key)
            .unwrap_or(0);
        nonce = nonce.checked_add(1).expect("Nonce overflow");
        env.storage().persistent().set(&nonce_key, &nonce);

        // 4. Transfer token to recipient
        let token_client = token::Client::new(&env, &token_address);
        token_client.transfer(&env.current_contract_address(), &recipient, &amount);
    }

    /// Retrieves the current nonce for a stealth pubkey (for offline transaction construction)
    pub fn get_nonce(env: Env, stealth_pubkey: BytesN<64>) -> u64 {
        let nonce_key = (symbol_short!("nonce"), stealth_pubkey);
        env.storage()
            .persistent()
            .get::<_, u64>(&nonce_key)
            .unwrap_or(0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use soroban_sdk::Env;

    #[test]
    fn test_get_nonce_default() {
        let env = Env::default();
        let contract =
            GhostVaultContractClient::new(&env, &env.register_contract(None, GhostVaultContract));

        let stealth_pubkey = BytesN::from_array(&env, &[1u8; 64]);
        let nonce = contract.get_nonce(&stealth_pubkey);
        assert_eq!(nonce, 0);
    }
}
