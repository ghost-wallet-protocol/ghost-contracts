#!/usr/bin/env bash
set -euo pipefail

# Deploy script for Ghost Protocol contracts
# Usage: ./scripts/deploy.sh <network>
# Networks: testnet, mainnet

NETWORK=${1:-testnet}
RPC_URL=""
NETWORK_PASSPHRASE=""

case "$NETWORK" in
  testnet)
    RPC_URL="https://soroban-testnet.stellar.org"
    NETWORK_PASSPHRASE="Test SDF Network ; September 2015"
    ;;
  mainnet)
    RPC_URL="https://soroban-mainnet.stellar.org"
    NETWORK_PASSPHRASE="Public Global Stellar Network ; September 2015"
    ;;
  *)
    echo "Unknown network: $NETWORK"
    echo "Usage: ./scripts/deploy.sh <testnet|mainnet>"
    exit 1
    ;;
esac

echo "Deploying to $NETWORK"
echo "RPC URL: $RPC_URL"

# Check for soroban-cli
if ! command -v soroban &> /dev/null; then
    echo "Error: soroban-cli not found"
    echo "Install: cargo install soroban-cli"
    exit 1
fi

# Check for environment variables
if [ -z "${SOROBAN_ACCOUNT:-}" ]; then
    echo "Error: SOROBAN_ACCOUNT not set"
    echo "Set your account address: export SOROBAN_ACCOUNT=G..."
    exit 1
fi

# Deploy Announcer Contract
echo ""
echo "Deploying Announcer Contract..."
ANNOUNCER_ID=$(soroban contract deploy \
  --source $SOROBAN_ACCOUNT \
  --rpc-url $RPC_URL \
  --network $NETWORK \
  --wasm contracts/announcer/target/wasm32-unknown-unknown/release/ghost_announcer.wasm)

echo "Announcer Contract ID: $ANNOUNCER_ID"

# Deploy Vault Contract
echo ""
echo "Deploying Vault Contract..."
VAULT_ID=$(soroban contract deploy \
  --source $SOROBAN_ACCOUNT \
  --rpc-url $RPC_URL \
  --network $NETWORK \
  --wasm contracts/vault/target/wasm32-unknown-unknown/release/ghost_vault.wasm)

echo "Vault Contract ID: $VAULT_ID"

# Output summary
echo ""
echo "========================================="
echo "Deployment Summary ($NETWORK)"
echo "========================================="
echo "Announcer: $ANNOUNCER_ID"
echo "Vault:     $VAULT_ID"
echo ""
echo "Add to your .env files:"
echo "ANNOUNCER_CONTRACT_ID=$ANNOUNCER_ID"
echo "VAULT_CONTRACT_ID=$VAULT_ID"
echo "SOROBAN_RPC_URL=$RPC_URL"
