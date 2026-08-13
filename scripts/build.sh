#!/usr/bin/env bash
set -euo pipefail

# Build script for Ghost Protocol contracts and SDK
# This script builds all contracts to WASM and generates TypeScript bindings

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building Ghost Protocol...${NC}"

# Check dependencies
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Error: cargo not found. Install Rust: https://rustup.rs/${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm not found. Install Node.js${NC}"
    exit 1
fi

# Ensure wasm target is installed
rustup target add wasm32-unknown-unknown

# Build contracts
echo -e "${YELLOW}Building Soroban contracts...${NC}"
cd contracts

# Build announcer contract
echo -e "${YELLOW}  Building announcer contract...${NC}"
cd announcer
cargo build --release --target wasm32-unknown-unknown
cd ..

# Build vault contract
echo -e "${YELLOW}  Building vault contract...${NC}"
cd vault
cargo build --release --target wasm32-unknown-unknown
cd ..

cd ..

echo -e "${GREEN}✓ Contracts built successfully${NC}"

# Build TypeScript SDK
echo -e "${YELLOW}Building TypeScript SDK...${NC}"
cd sdk
npm install
npm run build
cd ..

echo -e "${GREEN}✓ SDK built successfully${NC}"

# Build Relayer
echo -e "${YELLOW}Building Relayer...${NC}"
cd relayer
npm install
npm run build
cd ..

echo -e "${GREEN}✓ Relayer built successfully${NC}"

# Build Frontend
echo -e "${YELLOW}Building Frontend...${NC}"
cd frontend
npm install
npm run build
cd ..

echo -e "${GREEN}✓ Frontend built successfully${NC}"

echo -e "${GREEN}✅ All builds completed successfully!${NC}"
echo ""
echo "Build outputs:"
echo "  - Contracts WASM: contracts/*/target/wasm32-unknown-unknown/release/"
echo "  - SDK: sdk/dist"
echo "  - Relayer: relayer/dist"
echo "  - Frontend: frontend/build"
