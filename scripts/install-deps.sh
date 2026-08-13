#!/usr/bin/env bash
# Install all dependencies for the project

set -euo pipefail

echo "Installing Ghost Protocol dependencies..."

# Install Rust dependencies
echo "Installing Rust toolchain..."
cd contracts && cargo fetch && cd ..

# Install Node dependencies
echo "Installing Node.js dependencies..."
cd sdk && npm ci && cd ..
cd relayer && npm ci && cd ..
cd frontend && npm ci && cd ..

echo "✅ All dependencies installed!"
