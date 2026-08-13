#![no_std]

use soroban_sdk::{contract, contractimpl, symbol_short, Bytes, BytesN, Env, Symbol};

/// Announcer contract that broadcasts stealth transfer events for client-side scanning
#[contract]
pub struct GhostAnnouncerContract;

#[contractimpl]
impl GhostAnnouncerContract {
    /// Broadcasts a stealth transfer event on-chain for indexing/scanning.
    ///
    /// # Arguments
    /// * `env` - Soroban environment
    /// * `stealth_address` - 64-byte stealth address
    /// * `ephemeral_pubkey` - 64-byte ephemeral public key for this transfer
    /// * `view_tag` - View tag to optimize scanning
    /// * `metadata` - Optional metadata (amount, token, recipient hint)
    pub fn announce(
        env: Env,
        stealth_address: BytesN<64>,
        ephemeral_pubkey: BytesN<64>,
        view_tag: u32,
        metadata: Bytes,
    ) {
        // Emit an event that client-side wallets and indexer relayers listen for
        env.events().publish(
            (symbol_short!("announce"), stealth_address.clone()),
            (ephemeral_pubkey, view_tag, metadata),
        );
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use soroban_sdk::Env;

    #[test]
    fn test_announce_event() {
        let env = Env::default();
        let contract = GhostAnnouncerContractClient::new(&env, &env.register_contract(None, GhostAnnouncerContract));

        let stealth_addr = BytesN::from_array(&env, &[1u8; 64]);
        let ephemeral_key = BytesN::from_array(&env, &[2u8; 64]);
        let view_tag = 42u32;
        let metadata = Bytes::from_slice(&env, &[3u8; 32]);

        contract.announce(&stealth_addr, &ephemeral_key, &view_tag, &metadata);
        // Event should be published (verified by env.events() in integration tests)
    }
}
